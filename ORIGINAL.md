This project originally started as a stupid script, seen below.  I'm including it here so that it can be used for reference for the time being.

```ruby
require "yaml"
require "faraday"
require "fileutils"
require "nokogiri"
require "colorize"
require "tempfile"
require "uri"
require "thor"
require 'zip'

class ScrapeCLI < Thor
  no_commands do
    def _tempdir
      Dir.mktmpdir(KEY)
    end

    def _export_wp_site(site_url, **options)
      raise "Like I said, this doesn't work yet"
    end

    def _package(export_file, working_dir, output_dir, filename: "#{KEY}.zip", verbose: false)
      puts "Copying export definition from #{export_file.colorize(:yellow)} to #{working_dir.colorize(:yellow)}"
      FileUtils.copy(export_file, working_dir)

      site_def = File.join(working_dir, File.basename(export_file))
      puts "Munging export definition at #{site_def.colorize(:magenta)}"
      # munge export file to use new paths

      output_file = File.join(output_dir, filename)
      puts "Generating archive at #{output_file.colorize(:light_green)}..."
      ZipFileGenerator.new(working_dir, output_file).write

      puts "Archive created at #{output_file.colorize(:cyan)}"
    end

    def _scrape(export_file, output_dir, verbose: false)
      _enumerate(export_file, output_dir, verbose: verbose) do |work|
        # prime faraday
        rhost = URI.parse(work.first[0])
        rurl = "#{rhost.scheme}://#{rhost.host}"
        puts "Scraping from #{rurl.colorize(:cyan)}"
        faraday = Faraday.new(url: rurl)

        work.each do |(src, dst)|
          puts "Downloading #{src.colorize(:red)} to #{dst.colorize(:cyan)}."

          if File.exists?(dst)
            puts "\tDestination file #{dst.colorize(:yellow)} already exists."
          else
            subdir = File.dirname(dst)
            FileUtils.mkdir_p(subdir, verbose: true)

            size = File.open(File.expand_path(dst), "wb") do |f|
              filepath = URI.parse(src).path
              puts "GETting #{filepath.colorize(:light_green)}..."
              f.write(faraday.get(filepath).body)
            end

            puts "Wrote #{size.to_s.colorize(:light_green)} bytes to #{dst.colorize(:cyan)}."
          end
        end
      end
    end

    def _enumerate(export_file, output_dir, verbose: false)
      doc = Nokogiri::XML(File.open(export_file))

      workfile = Tempfile.new([KEY, ".yml"])
      puts "Using workfile at #{workfile.path.colorize(:yellow)}" if verbose

      begin
        urls = doc.css("wp|attachment_url").map(&:children).flatten.map(&:content).uniq.sort
        if options[:verbose]
          puts "  Scraping files at:"
          urls.each do |u|
            puts "  - #{u.colorize(:light_green)}"
          end
        end
        workfile.write(urls.to_yaml)
        workfile.rewind

        work = YAML::load_file(workfile.path).map do |original|
          puts "Munging path for #{original.colorize(:magenta)}..." if verbose

          begin
            path = URI.parse(original).path
            partial = path.split('/')[2..-1]
            rejoined = partial.join('/')
            munged = "#{output_dir}/assets/images/#{rejoined}"

            puts "  to #{munged.colorize(:light_green)}" if verbose

            [original, munged]
          rescue URI::InvalidURIError => e
            puts "  ! Could not parse URI #{original}".colorize(:red)

            nil
          end
        end.compact

        yield(work) if block_given?
      ensure
        workfile.close
      end
    end

  class ZipFileGenerator
    # Initialize with the directory to zip and the location of the output archive.
    def initialize(inputDir, outputFile)
      @inputDir = inputDir
      @outputFile = outputFile
    end

    # Zip the input directory.
    def write
      io = Zip::File.open(@outputFile, Zip::File::CREATE)

      writeEntries(_entries_at(@inputDir), "", io)
      io.close()
    end

    # A helper method to make the recursion work.
    private
      def _entries_at(path)
        entries = Dir.entries(@inputDir)
        entries.delete(".")
        entries.delete("..")
        entries.delete(".DS_Store")

        entries
      end

      def writeEntries(entries, path, io)
        entries.each do |e|
          zipFilePath = path == "" ? e : File.join(path, e)
          diskFilePath = File.join(@inputDir, zipFilePath)
          # puts "Deflating " + diskFilePath

          if File.directory?(diskFilePath)
            io.mkdir(zipFilePath)

            writeEntries(_entries_at(diskFilePath), zipFilePath, io)
          else
            io.get_output_stream(zipFilePath) do |f|
              f.puts(File.open(diskFilePath, "rb").read())
            end
          end
        end
      end
    end
  end
end

ScrapeCLI.start(ARGV)
```
