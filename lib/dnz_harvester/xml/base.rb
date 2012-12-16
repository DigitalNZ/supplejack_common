module DnzHarvester
  module Xml
    class Base < DnzHarvester::Base

      self._base_urls[self.identifier] = []
      self._attribute_definitions[self.identifier] = {}

      class_attribute :_record_url_selector
      class_attribute :_record_selector

      class << self
        def records(options={})
          options.reverse_merge!(limit: nil)

          if sitemap?
            sitemap_records(options)
          else
            xml_records(options)
          end
        end

        def sitemap_records(options={})
          url_nodes = index_document.xpath("#{self._record_url_selector}")
          url_nodes = url_nodes[0..(options[:limit].to_i-1)] if options[:limit]
          url_nodes.map {|node| new(node.text) }
        end

        def xml_records(options={})
          xml_nodes = index_document.xpath(self._record_selector)
          xml_nodes = xml_nodes[0..(options[:limit].to_i-1)] if options[:limit]
          xml_nodes.map {|node | new(node) }
        end

        def record_url_selector(xpath)
          self._record_url_selector = xpath
        end

        def record_selector(xpath)
          self._record_selector = xpath
        end

        def sitemap?
          self._record_url_selector.present?
        end

        def index_document
          @index_document ||= begin
            doc = Nokogiri.parse(self.index_xml)
            doc.remove_namespaces!
            doc
          end
        end

        def index_xml
          if base_urls.first.match(/^https?/)
            DnzHarvester::Utils.get(base_urls.first)
          elsif base_urls.first.match(/^file/)
            File.read(base_urls.first.gsub(/file:\//, ""))
          end
        end
      end

      def initialize(url_or_node)
        if url_or_node.is_a?(String)
          @url = url_or_node
        else
          @document = url_or_node
        end

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
        @document ||= begin
          xml = DnzHarvester::Utils.get(self.url)
          Nokogiri.parse(xml)
        end
      end

      def strategy_value(options={})
        nil
      end
    end
  end
end