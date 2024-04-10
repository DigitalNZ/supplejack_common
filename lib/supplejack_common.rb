# frozen_string_literal: true

require 'active_support/all'
require 'active_model'
require 'mongoid'
require 'nokogiri'
require 'oai'
require 'rest_client'
require 'jsonpath'
require 'chronic'
require 'loofah'
require 'aws-sdk-s3'

require 'supplejack_common/version'
require 'supplejack_common/exceptions'
require 'supplejack_common/utils'
require 'supplejack_common/scope'
require 'supplejack_common/xml_helpers'
require 'supplejack_common/attribute_value'
require 'supplejack_common/modifiers'
require 'supplejack_common/validations'
require 'supplejack_common/dsl'
require 'supplejack_common/base'
require 'supplejack_common/paginated_collection'
require 'supplejack_common/request'
require 'supplejack_common/attribute_builder'
require 'supplejack_common/enrichments'
require 'supplejack_common/resource'
require 'supplejack_common/fragment_wrap'
require 'supplejack_common/loader'
require 'supplejack_common/dsl/sitemap'

require 'supplejack_common/oai'
require 'supplejack_common/rss'
require 'supplejack_common/xml'
require 'supplejack_common/json'
require 'supplejack_common/sitemap'

require 'supplejack_common/parser/supplejack_common'

# SupplejackCommon module
module SupplejackCommon
  class << self
    attr_accessor :caching_enabled, :parser_base_path

    def redis
      @redis ||= Redis.new
    end
  end
end
