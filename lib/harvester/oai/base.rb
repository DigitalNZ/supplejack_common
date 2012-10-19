require 'open-uri'

module Harvester
  module Oai
    class Base < Harvester::Base

      self._base_urls = []
      self._attribute_definitions = {}

      class_attribute :_enrichment_definitions
      self._enrichment_definitions = {}

      attr_reader :record

      class << self
        def enrich(name, options={})
          self._enrichment_definitions[name] = options || {}
        end

        def client
          @@client ||= OAI::Client.new(self._base_urls.first)
        end

        def records
          @@records ||= client.list_records.map do |record|
            self.new(record)
          end
        end
      end

      def initialize(record)
        @record = record
        super
      end

      def set_attribute_values
        root = record.metadata.first
        @original_attributes[:identifier] = record.header.identifier

        self.class._attribute_definitions.each do |name, options|
          value = nil
          value = options[:default] if options[:default].present?
          value = extract_value_from(options[:from], root) unless value
          @original_attributes[name] = value
        end
      end

      def attributes
        self.enrich_record
        super
      end

      def attribute_names
        super + self._enrichment_definitions.keys
      end

      def extract_value_from(element_name, rexml_element)
        values = rexml_element.get_elements(element_name)
        values = values.map(&:texts).flatten.map(&:to_s) if values.try(:any?)
        values
      end

      def enrichment_document
        @enrichment_document ||= Nokogiri.parse(open(self.enrichment_url))
      end

      def enrich_record
        url = self.enrichment_url
        return nil if url.blank?
        
        self._enrichment_definitions.each do |name, options|
          nodes = enrichment_document.xpath("//#{options[:xpath]}")

          conditions = options[:if]
          condition_xpath = conditions.keys.first
          condition_value = conditions.values.first
          node = nodes.detect {|n| n.xpath(condition_xpath).text == condition_value }

          if node
            @original_attributes[name] = node.xpath(options[:value]).text
          end
        end
      end
    end
  end
end