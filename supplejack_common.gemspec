# -*- encoding: utf-8 -*-

# The Supplejack Common code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack 

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'supplejack_common/version'

Gem::Specification.new do |gem|
  gem.name          = "supplejack_common"
  gem.version       = SupplejackCommon::VERSION
  gem.authors       = ["DigitalNZ"]
  gem.email         = ["info@digitalnz.org"]
  gem.description   = %q{Supplejack Common provides a DSL to harvest records of different sources}
  gem.summary       = %q{Supplejack Common provides a DSL to harvest records of different sources}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency "activesupport",   "~> 3.2"
  gem.add_runtime_dependency "actionpack",      "~> 3.2"
  gem.add_runtime_dependency "redis",           "~> 3"
  gem.add_runtime_dependency "mongoid",         "~> 3.1.3"

  gem.add_runtime_dependency "nokogiri"
  gem.add_runtime_dependency "rest-client",     "~> 1.6.7"
  gem.add_runtime_dependency "jsonpath",        "~> 0.5.0"
  gem.add_runtime_dependency "chronic",         "~> 0.8.0"
  gem.add_runtime_dependency "tzinfo"
  gem.add_runtime_dependency "dimensions"
  gem.add_runtime_dependency "mimemagic"
  gem.add_runtime_dependency "json",            "~> 1.7.7"

  gem.add_development_dependency "rake"
  gem.add_development_dependency "rspec",      "~> 2.11.0"
  gem.add_development_dependency "webmock",    "~> 1.8"
end