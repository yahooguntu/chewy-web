# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "chewy/web/version"

Gem::Specification.new do |spec|
  spec.name          = "chewy-web"
  spec.version       = Chewy::Web::VERSION
  spec.authors       = ["Mitch Birti"]
  spec.email         = ["yahooguntu@gmail.com"]

  spec.summary       = "A simple web frontend for managing Chewy indices."
  spec.description   = "Allows you to quickly see the status of indices, and trigger reset/sync operations with various options."
  spec.homepage    = "https://www.birti.net/chewy-web"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.require_paths = ["lib"]

  spec.add_dependency 'sidekiq'
  spec.add_dependency 'chewy', "~> 5"
  spec.add_dependency 'sinatra'

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency 'byebug'
end
