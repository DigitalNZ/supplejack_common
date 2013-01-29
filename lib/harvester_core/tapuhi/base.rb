# encoding: ISO-8859-1

module HarvesterCore
  module Tapuhi
    class Base < HarvesterCore::Base

      self.clear_definitions

      class_attribute :_run_length_bytes

      self._run_length_bytes = {}

      class << self
        def records(options={})
          HarvesterCore::Tapuhi::PaginatedCollection.new(self, base_urls, options[:limit])
        end

        def run_length_bytes(size)
          self._run_length_bytes[self.identifier] = size.to_i
        end

        def get_run_length_bytes
          self._run_length_bytes[self.identifier]
        end

        def clear_definitions
          super
          self._run_length_bytes = {}
        end
      end

      attr_reader :tapuhi_source

      def initialize(tapuhi_source)
        @tapuhi_source = tapuhi_source.force_encoding("ISO-8859-1")
        super
      end

      def strategy_value(options={}, document=nil)
        fields[options[:field_num].to_i]
      end

      def fields
        @fields ||= parse_tapuhi_source
      end

      def parse_tapuhi_source
        fields = tapuhi_source.split(/\xFE/)
        fields = fields.map {|field| field.split(/\xFD/) }
      end

      def raw_data
        @raw_data ||= begin
          hash = {}
          fields.each_with_index do |field, index|
            hash[index] = field if field.present?
          end
          hash
        end
      end

      def fetch(integer)
        HarvesterCore::AttributeValue.new(fields[integer.to_i])
      end
    end
  end
end