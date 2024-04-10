# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in supplejack_common.gemspec
gemspec

group :development do
  gem 'codeclimate_diff', github: 'boost/codeclimate_diff'
  gem 'rake', '> 12.3.3'
  gem 'rubocop', require: false
end

group :test do
  gem 'mock_redis'
  gem 'rspec', '~> 2.14'
  gem 'webmock'
end

group :test, :development do
  gem 'pry-byebug'
end
