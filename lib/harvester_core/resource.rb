module HarvesterCore
  class Resource
    include HarvesterCore::Modifiers
    
    attr_reader :url, :throttling_options, :attributes, :request_timeout

    def initialize(url, options={})
      @url = url
      @throttling_options = options[:throttling_options] || {}
      @request_timeout = options[:request_timeout] || 60000
      @attributes = options[:attributes] || {}
    end

    def strategy_value(options)
      raise NotImplementedError.new("All subclasses of HarvesterCore::Resource must override #strategy_value.")
    end

    def fetch(params)
      raise NotImplementedError.new("All subclasses of HarvesterCore::Resource must override #fetch.")
    end

    protected
    
    def fetch_document
      HarvesterCore::Request.get(url, request_timeout, throttling_options)
    end
  end
end

require "harvester_core/resources/xml_resource"
require "harvester_core/resources/html_resource"
require "harvester_core/resources/json_resource"
require "harvester_core/resources/file_resource"