module DnzHarvester
  module Xml
    class Base < DnzHarvester::Base

      self._base_urls[self.identifier] = []
      self._attribute_definitions[self.identifier] = {}

      class_attribute :_record_url_xpath

      class << self
        def records(options={})
          options.reverse_merge!(limit: nil)

          url_nodes = index_document.xpath("#{self._record_url_xpath}")
          url_nodes = url_nodes[0..(options[:limit].to_i-1)] if options[:limit]
          url_nodes.map {|node| new(node.text) }
        end

        def record_url_xpath(xpath)
          self._record_url_xpath = xpath
        end

        def index_document
          @index_document ||= Nokogiri.parse(RestClient.get(base_urls.first))
        end
      end

      def initialize(url)
        @url = url
        super
      end

      def url
        if self.class.basic_auth_credentials
          @url.gsub("http://", "http://#{self.class.basic_auth_credentials[:username]}:#{self.class.basic_auth_credentials[:password]}@")
        else
          @url
        end
      end

      def document
        xml = DnzHarvester::Utils.get(self.url)
        @document ||= Nokogiri.parse(xml)
      end
    end
  end
end