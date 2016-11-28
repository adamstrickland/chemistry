# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'chemistry/version'

Gem::Specification.new do |spec|
  spec.name          = "chemistry"
  spec.version       = Chemistry::VERSION
  spec.authors       = ["Adam Strickland"]
  spec.email         = ["adam.strickland@gmail.com"]

  spec.summary       = %q{Convert your WordPress to Jekyll, __with science__!!!}
  spec.description   = %q{Sick of WordPress?  Me too.  I prefer Jekyll (immensely).  So I wrote a tool to inhale a sickly WordPress and exhale a Jekyll}
  spec.homepage      = "http://www.github.com/adamstrickland/chemistry"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday", "~> 0.10"
  spec.add_dependency "nokogiri", "~> 1.6.7.2"
  spec.add_dependency "colorize", "~> 0.8.1"
  spec.add_dependency "thor", "~> 0.19.1"
  spec.add_dependency "rubyzip", "~> 1.2.0"

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
