# frozen_string_literal: true

require 'pry'
require 'supplejack_common'
require 'webmock/rspec'
require 'loofah'

RSpec.configure do |config|
  config.raise_errors_for_deprecations!
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
end

Mongoid.configure do |config|
  config.load!('spec/support/mongoid.yml', 'test')
end
