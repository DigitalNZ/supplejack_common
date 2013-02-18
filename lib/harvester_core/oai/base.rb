module HarvesterCore
  module Oai
    class Base < HarvesterCore::Base
      include HarvesterCore::XmlMethods

      self.clear_definitions

      class_attribute :_enrichment_definitions
      self._enrichment_definitions = {}

      VALID_RECORDS_OPTIONS = [:from, :limit]

      attr_reader :oai_record, :root

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

      def initialize(oai_record)
        @oai_record = oai_record
        super
      end

      def deleted?
        self.oai_record.try(:deleted?)
      end

      def set_attribute_values
        metadata_nodes = oai_record.metadata || []
        metadata_nodes = metadata_nodes.map {|node| node if node.to_s.present? }.compact
        @root = metadata_nodes.try(:first)
        @original_attributes[:identifier] = oai_record.header.identifier

        super
      end

      def attributes
        self.enrich_record
        super
      end

      def attribute_names
        super + self._enrichment_definitions.keys
      end

      def strategy_value(options={})
        options ||= {}
        return nil if root.nil? || options[:from].blank?

        values = []
        selectors = Array(options[:from])
        selectors.each do |selector|
          values += root.get_elements(selector)
        end

        values = values.map(&:texts).flatten.map(&:to_s) if values.try(:any?)
        values
      end

      def document
        @document ||= begin
          xml = oai_record.element.to_s
          xml = HarvesterCore::Utils.remove_default_namespace(xml)
          Nokogiri.parse(xml)
        end
      end

      def raw_data
        @raw_data ||= document.to_xml
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
