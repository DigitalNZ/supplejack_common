# frozen_string_literal: true

require 'supplejack_common/xml/base'

Dir[File.dirname(__FILE__) + '/xml/*.rb'].each { |file| require file }
