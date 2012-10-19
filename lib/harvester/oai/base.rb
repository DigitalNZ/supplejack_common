module Harvester
  module Oai
    class Base < Harvester::Base

      self._base_urls = []
      self._attribute_definitions = {}

      attr_reader :record

      class << self
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

      def extract_value_from(element_name, rexml_element)
        values = rexml_element.get_elements(element_name)
        values = values.map(&:texts).flatten if values.try(:any?)
        values
      end
    end
  end
end