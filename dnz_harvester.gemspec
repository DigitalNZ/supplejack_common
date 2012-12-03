# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dnz_harvester/version'

Gem::Specification.new do |gem|
  gem.name          = "dnz_harvester"
  gem.version       = DnzHarvester::VERSION
  gem.authors       = ["Federico Gonzalez"]
  gem.email         = ["fedegl@gmail.com"]
  gem.description   = %q{DNZ Harvester project which provides a DSL to harvest records of different sources}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency "oai",            "~> 0.2.1"
  gem.add_runtime_dependency "feedzirra",      "~> 0.1.3"
  gem.add_runtime_dependency "activesupport"
  gem.add_runtime_dependency "rest-client",    "~> 1.6.7"

  gem.add_development_dependency "rspec",      "~> 2.11.0"
  gem.add_development_dependency "guard"
  gem.add_development_dependency "guard-rspec"
end
