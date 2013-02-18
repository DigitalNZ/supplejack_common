require 'active_support/all'
require 'nokogiri'
require 'oai'
require 'rest_client'
require 'jsonpath'
require 'chronic'

require "harvester_core/version"
require "harvester_core/exceptions"
require "harvester_core/utils"
require "harvester_core/scope"
require "harvester_core/xml_helpers"
require "harvester_core/attribute_value"
require "harvester_core/modifiers"
require "harvester_core/option_transformers"
require "harvester_core/base"
require "harvester_core/paginated_collection"
require "harvester_core/request"

require "harvester_core/oai"
require "harvester_core/rss"
require "harvester_core/xml"
require "harvester_core/json"
require "harvester_core/tapuhi"

module HarvesterCore
  # Your code goes here...

  class << self
    attr_accessor :caching_enabled

    def redis
      @redis ||= Redis.new
    end
  end
end