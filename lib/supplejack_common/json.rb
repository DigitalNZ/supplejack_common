# frozen_string_literal: true

require 'supplejack_common/json/base'

Dir[File.dirname(__FILE__) + '/json/*.rb'].each { |file| require file }
