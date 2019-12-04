# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in supplejack_common.gemspec
gemspec

group :development do
  gem 'pry-byebug'
  gem 'rake', '< 11.0'
  gem 'rubocop', require: false
end

group :test do
  gem 'mock_redis'
  gem 'rspec', '~> 2.11.0'
  gem 'simplecov'
  gem 'webmock', '~> 1.8'
end
