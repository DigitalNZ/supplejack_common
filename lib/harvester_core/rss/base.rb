module HarvesterCore
  module Rss
    class Base < HarvesterCore::Base
      include HarvesterCore::XmlMethods

      self.clear_definitions

      attr_accessor :original_xml

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
          xml = HarvesterCore::Request.get(base_urls.first, self._throttle)
          xml = HarvesterCore::Utils.remove_default_namespace(xml)
          Nokogiri.parse(xml)
        end

        def xml_records
          xml_nodes = index_document.xpath(self._record_selector)
          xml_nodes.map {|node | new(node) }
        end
      end

      def initialize(xml, from_raw=false)
        @original_xml = xml
        @original_xml = xml.to_xml if xml.respond_to?(:to_xml)
        super
      end

      def document
        @document ||= begin
          xml = HarvesterCore::Utils.remove_default_namespace(original_xml)
          Nokogiri.parse(xml)
        end
      end

    end
  end
end