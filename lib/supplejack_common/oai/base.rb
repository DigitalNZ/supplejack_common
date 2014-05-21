# The Supplejack Common code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack 

module SupplejackCommon
  module Oai
    class Base < SupplejackCommon::Base
      include SupplejackCommon::XmlDslMethods
      include SupplejackCommon::XmlDataMethods

      self.clear_definitions

      VALID_RECORDS_OPTIONS = [:from, :limit]

      attr_reader :original_xml

      class_attribute :_metadata_prefix
      self._metadata_prefix = {}

      class_attribute :_set
      self._set = {}

      class << self
        attr_reader :response

        def client
          @client ||= OAI::Client.new(self.base_urls.first)
        end

        def records(options={})
          options = options.keep_if {|key| VALID_RECORDS_OPTIONS.include?(key) }
          options[:metadata_prefix] = get_metadata_prefix if get_metadata_prefix.present?
          options[:set] = get_set if get_set.present?
          
          SupplejackCommon::Oai::PaginatedCollection.new(client, options, self)
        end

        def resumption_token
          self.response.try(:resumption_token)
        end

        def clear_definitions
          super
          self._metadata_prefix = {}
          self._set = {}
        end

        def metadata_prefix(prefix)
          self._metadata_prefix[self.identifier] = prefix
        end

        def get_metadata_prefix
          self._metadata_prefix[self.identifier]
        end

        def set(name)
          self._set[self.identifier] = name
        end

        def get_set
          self._set[self.identifier]
        end

      end

      def initialize(xml, from_raw=false)
        @original_xml = xml
        @original_xml = xml.element.to_s if xml.respond_to?(:element)
        super
      end

      def document
        @document ||= begin
          doc = Nokogiri::XML.parse(original_xml)
        end
      end

      def deletable?
        document.xpath("record/header[@status='deleted']").any?
      end
    end
  end
end
