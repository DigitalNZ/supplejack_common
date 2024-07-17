# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'supplejack_common/version'

Gem::Specification.new do |gem|
  gem.required_ruby_version = '>= 3.2.2'
  gem.name          = 'supplejack_common'
  gem.version       = SupplejackCommon::VERSION
  gem.authors       = ['DigitalNZ']
  gem.email         = ['info@digitalnz.org']
  gem.description   = 'Supplejack Common provides a DSL to harvest records of different sources'
  gem.summary       = 'Supplejack Common provides a DSL to harvest records of different sources'
  gem.homepage      = ''
  gem.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.metadata['rubygems_mfa_required'] = 'true'
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.require_paths = ['lib']

  gem.add_dependency 'actionpack', '>= 7.0.0'
  gem.add_dependency 'activesupport', '>= 7.0.0'
  gem.add_dependency 'aws-sdk-s3'
  gem.add_dependency 'chronic', '<= 0.10.2'
  gem.add_dependency 'dimensions'
  gem.add_dependency 'faraday', '~> 2.0'
  gem.add_dependency 'faraday-retry'
  gem.add_dependency 'htmlentities'
  gem.add_dependency 'json', '>= 2.3.0'
  gem.add_dependency 'jsonpath', '~> 0.5.0'
  gem.add_dependency 'loofah'
  gem.add_dependency 'mimemagic'
  gem.add_dependency 'mongoid'
  gem.add_dependency 'nokogiri'
  gem.add_dependency 'oai'
  gem.add_dependency 'redis'
  gem.add_dependency 'rest-client'
  gem.add_dependency 'retriable'
  gem.add_dependency 'sanitize'
  gem.add_dependency 'tzinfo'
end
