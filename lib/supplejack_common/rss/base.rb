# frozen_string_literal: true

module SupplejackCommon
  module Rss
    class Base < SupplejackCommon::Base
      include SupplejackCommon::XmlDslMethods
      include SupplejackCommon::XmlDataMethods

      clear_definitions

      attr_accessor :original_xml

      class << self
        def _record_selector
          '//item'
        end

        def records(options = {})
          SupplejackCommon::PaginatedCollection.new(self, {}, options)
        end

        def fetch_records(url, channel_options = {})
          document = index_document(url, channel_options)
          xml_nodes = document.xpath(_record_selector, _namespaces)
          xml_nodes.map { |node| new(node) }
        end

        def index_document(url, channel_options)
          xml = SupplejackCommon::Request.get(url, _request_timeout, _throttle, _http_headers, _proxy, channel_options)
          Nokogiri::XML.parse(xml)
        end
      end

      def initialize(xml, from_raw = false)
        @original_xml = xml
        @original_xml = xml.to_xml if xml.respond_to?(:to_xml)
        super
      end

      def document
        @document ||= begin
          xml = original_xml
          Nokogiri::XML.parse(xml)
        end
      end
    end
  end
end
