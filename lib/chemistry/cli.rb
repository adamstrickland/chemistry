require "thor"

module Chemistry
  class CLI < Thor
    DEFAULT_OUTPUT_DIR = "./#{Chemistry::KEY}"
    DEFAULT_ARCHIVE_FILE = "#{Chemistry::KEY}.zip"

    class_option :verbose, type: :boolean, default: false, aliases: ["v"]

    # NOTES:
    #   - does thor have option groups?

    desc "concoct WORDPRESS_URL OUTPUT_DIR", "scrape that monstrosity at WORDPRESS_URL and create a Jekyll at OUTPUT_DIR"
    option :username, type: :string, aliases: [:u], description: "WP-Admin user"
    option :password, type: :string, aliases: [:p], description: "WP-Admin user's password"
    def concoct(wordpress_url, output_dir)
      archive_file = extract(wordpress_url, Dir.mktmpdir(Chemistry::KEY))
      Jekyllizer.build_from_archive(archive_file, output_dir)
    end

    desc "extract WORDPRESS_URL [OUTPUT_DIR]", "scrape that monstrosity at WORDPRESS_URL and build an archive at OUTPUT_DIR (default: #{DEFAULT_OUTPUT_DIR})"
    option :username, type: :string, require: true, aliases: [:u], description: "WP-Admin user"
    option :password, type: :string, require: true, aliases: [:p], description: "WP-Admin user's password"
    option :filename, type: :string, default: DEFAULT_ARCHIVE_FILE, aliases: [:f]
    def extract(wordpress_url, output_dir = DEFAULT_OUTPUT_DIR)
      wordpress_export_file = WordPressMustDie.wp_admin(options[:username], options[:password]) do
        download_export
      end
      archive(wordpress_export_file, output_dir)
    end

    desc "archive WORDPRESS_EXPORT_FILE [OUTPUT_DIR]", "generate an archive based on WORDPRESS_EXPORT_FILE and put it in OUTPUT_DIR (default: #{DEFAULT_OUTPUT_DIR})"
    option :filename, type: :string, default: DEFAULT_ARCHIVE_FILE, aliases: [:f]
    def archive(wordpress_export_file, output_dir = DEFAULT_OUTPUT_DIR)
      archive_file = File.join(output_dir, options[:filename])
      WordPressMustDie.create_archive_from_export(wordpress_export_file, archive_file)
    end

    # desc "execute WP_URL", "scrape, munge & package the site at WP_URL"
    # option :username, type: :string, aliases: ["u"]
    # option :password, type: :string, aliases: ["p"]
    # option :output_dir, type: :string, default: DEFAULT_OUTPUT_DIR, aliases: ["o"]
    # option :filename, type: :string, default: DEFAULT_ARCHIVE_FILE, aliases: ["f"]
    # option :try, type: :boolean, default: false
    # def execute(wp_url)
    #   if options[:try]
    #     begin
    #       export_file = _export_wp_site(wp_url, username: options[:username], password: options[:password])
    #       working_dir = _tempdir
    #       _scrape(export_file, working_dir, verbose: options[:verbose])
    #       package(export_file, working_dir)
    #     rescue RuntimeError => e
    #       puts e.message.colorize(:red)
    #     end
    #   else
    #     puts "This doesn't work yet.  If you really want to give it a go, use --try.  YMMV".colorize(:yellow)
    #   end
    # end

    # desc "validate EXPORT_FILE", "list the files in EXPORT_FILE to be scraped"
    # def validate(export_file)
    #   _enumerate(export_file, _tempdir, verbose: options[:verbose])
    # end

    # desc "scrape EXPORT_FILE", "scrape the site in the EXPORT_FILE"
    # option :output_dir, type: :string, default: DEFAULT_OUTPUT_DIR, aliases: ["o"]
    # def scrape(export_file)
    #   _scrape(export_file, options[:output_dir], verbose: options[:verbose])
    # end

    # desc "package EXPORT_FILE WORKING_DIR", "munge & package the site defined in the EXPORT_FILE and the files in WORKING_DIR"
    # option :output_dir, type: :string, default: DEFAULT_OUTPUT_DIR, aliases: ["o"]
    # option :filename, type: :string, default: DEFAULT_ARCHIVE_FILE, aliases: ["f"]
    # def package(export_file, working_dir)
    #   _package(export_file, working_dir, options[:output_dir], filename: options[:filename], verbose: options[:verbose])
    # end
  end
end
