module DnzHarvester
  module Oai
    class Base < DnzHarvester::Base

      self._base_urls = []
      self._attribute_definitions = {}

      class_attribute :_enrichment_definitions
      self._enrichment_definitions = {}

      attr_reader :record, :root

      class << self
        def enrich(name, options={})
          self._enrichment_definitions[name] = options || {}
        end

        def client
          @client ||= OAI::Client.new(self.base_urls.first)
        end

        def records
          @records ||= client.list_records.map do |record|
            self.new(record)
          end
        end
      end

      def initialize(record)
        @record = record
        super
      end

      def set_attribute_values
        @root = record.metadata.first
        @original_attributes[:identifier] = record.header.identifier

        super
      end

      def attributes
        self.enrich_record
        super
      end

      def attribute_names
        super + self._enrichment_definitions.keys
      end

      def get_value_from(name)
        values = root.get_elements(name)
        values = values.map(&:texts).flatten.map(&:to_s) if values.try(:any?)
        values
      end

      def enrichment_document
        @enrichment_document ||= Nokogiri.parse(DnzHarvester::Utils.get(self.enrichment_url))
      end

      def enrich_record
        url = self.enrichment_url
        return nil if url.blank?
        
        self._enrichment_definitions.each do |name, options|
          conditional_option = DnzHarvester::ConditionalOption.new(enrichment_document, options)
          if conditional_option.value.present?
            @original_attributes[name] = conditional_option.value
          end
        end
      end
    end
  end
end