module HarvesterCore
  class Resource
    include HarvesterCore::Modifiers
    
    attr_reader :url, :throttling_options, :attributes

    def initialize(url, options={})
      @url = url
      @throttling_options = options[:throttling_options] || {}
      @attributes = {}
    end

    def fetch
      HarvesterCore::Request.get(url, throttling_options)
    end

    def strategy_value(options)
      nil
    end
  end
end

require "harvester_core/resources/xml_resource"
require "harvester_core/resources/html_resource"
require "harvester_core/resources/json_resource"
require "harvester_core/resources/file_resource"