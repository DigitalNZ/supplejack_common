module DnzHarvester
  module Sitemap
    class Base < DnzHarvester::Base

      self._base_urls = []
      self._attribute_definitions = {}

      class << self
        def sitemap_file
          @sitemap_file ||= File.read(self.base_urls.first)
        end

        def sitemap_document
          @sitemap_document ||= Nokogiri.parse(sitemap_file)
        end

        def record_urls
          sitemap_document.remove_namespaces!
          sitemap_document.xpath("//loc").map(&:text)
        end

        def records
          @records ||= record_urls.map do |url|
            new(url)
          end
        end
      end

      def initialize(url)
        @url = url
        super
      end

      def fetch_record_xml
        @record_xml ||= RestClient.get(@url)
      end

      def document
        @document ||= Nokogiri.parse(fetch_record_xml)
      end
    end
  end
end