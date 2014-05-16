# The Supplejack code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack_core 

module HarvesterCore
  module Rss
    class Base < HarvesterCore::Base
      include HarvesterCore::XmlDslMethods
      include HarvesterCore::XmlDataMethods

      self.clear_definitions

      attr_accessor :original_xml

      class << self
        def _record_selector
          "//item"
        end

        def records(options={})
          HarvesterCore::PaginatedCollection.new(self, {}, options)
        end

        def fetch_records(url)
          document = index_document(url)
          xml_nodes = document.xpath(self._record_selector, self._namespaces)
          xml_nodes.map {|node | new(node) }
        end

        def index_document(url)
          xml = HarvesterCore::Request.get(url, self._request_timeout, self._throttle)
          Nokogiri::XML.parse(xml)
        end
      end

      def initialize(xml, from_raw=false)
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