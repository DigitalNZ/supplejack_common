# frozen_string_literal: true

require 'pry'
require 'supplejack_common'
require 'webmock/rspec'
require 'loofah'
require 'mongoid'

RSpec.configure do |config|
  config.raise_errors_for_deprecations!
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
  config.example_status_persistence_file_path = 'spec/examples.txt'
end
