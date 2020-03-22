# frozen_string_literal: true

require 'supplejack_common'
require 'webmock/rspec'
require 'loofah'

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
end

Mongoid.configure do |config|
  config.load!('spec/support/mongoid.yml', 'test')
end
