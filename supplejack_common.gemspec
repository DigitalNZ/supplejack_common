# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'supplejack_common/version'

Gem::Specification.new do |gem|
  gem.name          = 'supplejack_common'
  gem.version       = SupplejackCommon::VERSION
  gem.authors       = ['DigitalNZ']
  gem.email         = ['info@digitalnz.org']
  gem.description   = 'Supplejack Common provides a DSL to harvest records of different sources'
  gem.summary       = 'Supplejack Common provides a DSL to harvest records of different sources'
  gem.homepage      = ''
  gem.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_runtime_dependency 'actionpack', '~> 6.0.3.5'
  gem.add_runtime_dependency 'activesupport'
  gem.add_runtime_dependency 'aws-sdk-s3'
  gem.add_runtime_dependency 'chronic', '<= 0.10.2'
  gem.add_runtime_dependency 'dimensions'
  gem.add_runtime_dependency 'htmlentities'
  gem.add_runtime_dependency 'json', '>= 2.3.0'
  gem.add_runtime_dependency 'jsonpath', '~> 0.5.0'
  gem.add_runtime_dependency 'loofah'
  gem.add_runtime_dependency 'mimemagic'
  gem.add_runtime_dependency 'mongoid', '~> 7.1.0'
  gem.add_runtime_dependency 'nokogiri'
  gem.add_runtime_dependency 'oai'
  gem.add_runtime_dependency 'redis'
  gem.add_runtime_dependency 'rest-client'
  gem.add_runtime_dependency 'retriable'
  gem.add_runtime_dependency 'sanitize'
  gem.add_runtime_dependency 'tzinfo'
end
