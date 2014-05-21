# encoding: ISO-8859-1

# The Supplejack Common code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack_core 


module SupplejackCommon
  module Tapuhi
    class Base < SupplejackCommon::Base

      self.clear_definitions

      class_attribute :_run_length_bytes

      self._run_length_bytes = {}

      class << self
        def records(options={})
          SupplejackCommon::Tapuhi::PaginatedCollection.new(self, base_urls, options[:limit])
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

      def initialize(source, from_raw=false)
        if from_raw
          @fields = JSON.parse(source)
        else
          @tapuhi_source = source.force_encoding("ISO-8859-1")
        end
        super
      end

      def strategy_value(options={})
        fields[options[:field_num].to_i] if options[:field_num].present?
      end

      def fields
        @fields ||= parse_tapuhi_source
      end

      def parse_tapuhi_source
        fields = tapuhi_source.split(/\xFE/)
        fields = fields.map {|field| field.split(/\xFD/) }
      end

      def document
        @document ||= begin
          hash = {}
          fields.each_with_index do |field, index|
            hash[index] = field if field.present?
          end
          hash
        end
      end

      def raw_data
        document.to_json
      end

      def full_raw_data
        fields.to_json
      end

      def fetch(integer)
        SupplejackCommon::AttributeValue.new(fields[integer.to_i])
      end
    end
  end
end