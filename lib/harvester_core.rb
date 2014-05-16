# The Supplejack code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack_core 

require 'active_support/all'
require 'active_model'
require 'mongoid'
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
require "harvester_core/validations"
require "harvester_core/dsl"
require "harvester_core/base"
require "harvester_core/paginated_collection"
require "harvester_core/request"
require "harvester_core/attribute_builder"
require "harvester_core/enrichments"
require "harvester_core/resource"
require "harvester_core/fragment_wrap"
require "harvester_core/loader"
require "harvester_core/dsl/sitemap"

require "harvester_core/oai"
require "harvester_core/rss"
require "harvester_core/xml"
require "harvester_core/json"
require "harvester_core/tapuhi"
require "harvester_core/sitemap"

require "harvester_core/parser/harvester_core"


module HarvesterCore

  class << self
    attr_accessor :caching_enabled
    attr_accessor :parser_base_path

    def redis
      @redis ||= Redis.new
    end
  end
end