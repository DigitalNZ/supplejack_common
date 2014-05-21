# The Supplejack Common code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack_core 

module SupplejackCommon
  class Resource
    include SupplejackCommon::Modifiers
    
    attr_reader :url, :throttling_options, :attributes, :request_timeout

    def initialize(url, options={})
      @url = url
      @throttling_options = options[:throttling_options] || {}
      @request_timeout = options[:request_timeout] || 60000
      @attributes = options[:attributes] || {}
    end

    def strategy_value(options)
      raise NotImplementedError.new("All subclasses of SupplejackCommon::Resource must override #strategy_value.")
    end

    def fetch(params)
      raise NotImplementedError.new("All subclasses of SupplejackCommon::Resource must override #fetch.")
    end

    protected
    
    def fetch_document
      SupplejackCommon::Request.get(url, request_timeout, throttling_options)
    end
  end
end

require "supplejack_common/resources/xml_resource"
require "supplejack_common/resources/html_resource"
require "supplejack_common/resources/json_resource"
require "supplejack_common/resources/file_resource"