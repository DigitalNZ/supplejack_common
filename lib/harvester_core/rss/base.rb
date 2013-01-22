module HarvesterCore
  module Rss
    class Base < HarvesterCore::Base

      self.clear_definitions

      class << self
        def _record_selector
          "//item"
        end

        def records(options={})
          options = options.try(:symbolize_keys) || {}

          records = xml_records
          records = records[0..(options[:limit].to_i-1)]

          @records = records.map do |record|
            record.set_attribute_values
            if rejection_rules
              record if !record.instance_eval(&rejection_rules)
            else
              record
            end
          end.compact
        end

        def index_document
          Nokogiri.parse(HarvesterCore::Utils.get(base_urls.first))
        end

        def xml_records
          xml_nodes = index_document.xpath(self._record_selector)
          xml_nodes.map {|node | new(node) }
        end
      end

      def initialize(node)
        @document = node
        super
      end

      def document
        @document
      end

      def raw_data
        @raw_data ||= document.to_xml
      end

      def strategy_value(options={})
        return nil
      end

    end
  end
end