module HarvesterCore
  module Oai
    class Base < HarvesterCore::Base
      include HarvesterCore::XmlMethods

      self.clear_definitions

      class_attribute :_enrichment_definitions
      self._enrichment_definitions = {}

      VALID_RECORDS_OPTIONS = [:from, :limit]

      attr_reader :original_xml

      class << self
        attr_reader :response

        def enrich_attribute(name, options={})
          self._enrichment_definitions[name] = options || {}
        end

        def client
          @client ||= OAI::Client.new(self.base_urls.first)
        end

        def records(options={})
          options = options.keep_if {|key| VALID_RECORDS_OPTIONS.include?(key) }
          HarvesterCore::Oai::PaginatedCollection.new(client, options, self)
        end

        def resumption_token
          self.response.try(:resumption_token)
        end

        def clear_definitions
          super
          self._enrichment_definitions = {}
        end
      end

      def initialize(xml, from_raw=false)
        @original_xml = xml
        @original_xml = xml.element.to_s if xml.respond_to?(:element)
        super
      end

      def attributes
        self.enrich_record
        super
      end

      def attribute_names
        super + self._enrichment_definitions.keys
      end

      def document
        @document ||= begin
          xml = HarvesterCore::Utils.remove_default_namespace(original_xml)
          doc = Nokogiri.parse(xml)
          doc.remove_namespaces!
          doc
        end
      end

      def get_enrichment_url
        @get_enrichment_url ||= begin
          if self.respond_to?(:enrichment_url) || self.class.attribute_definitions.has_key?(:enrichment_url)
            url = self.enrichment_url
            url.is_a?(Array) ? url.first : url
          else
            nil
          end
        end
      end

      def enrichment_document
        @enrichment_document ||= Nokogiri.parse(HarvesterCore::Request.get(self.get_enrichment_url, self._throttle))
      end

      def enrich_record
        url = self.get_enrichment_url
        return nil if url.blank?
        
        self._enrichment_definitions.each do |name, options|
          conditional_option = HarvesterCore::ConditionalOption.new(enrichment_document, options)
          if conditional_option.value.present?
            @original_attributes[name] = conditional_option.value
          end
        end
      end
    end
  end
end
