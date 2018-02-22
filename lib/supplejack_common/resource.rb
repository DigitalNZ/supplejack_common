module SupplejackCommon
  # SJ Resources
  class Resource
    include SupplejackCommon::Modifiers
    attr_reader :url, :throttling_options, :attributes, :request_timeout, :http_headers

    def initialize(url, options = {})
      @url = url
      @throttling_options = options[:throttling_options] || {}
      @request_timeout = options[:request_timeout] || 600_00
      @attributes = options[:attributes] || {}
      @http_headers = options[:http_headers] || {}
    end

    def strategy_value(options)
      raise NotImplementedError.new('All subclasses of SupplejackCommon::Resource must override #strategy_value.')
    end

    def fetch(params)
      raise NotImplementedError.new('All subclasses of SupplejackCommon::Resource must override #fetch.')
    end

    protected

    def fetch_document
      SupplejackCommon::Request.get(url, request_timeout, throttling_options, http_headers)
    end
  end
end

require 'supplejack_common/resources/xml_resource'
require 'supplejack_common/resources/html_resource'
require 'supplejack_common/resources/json_resource'
require 'supplejack_common/resources/file_resource'
