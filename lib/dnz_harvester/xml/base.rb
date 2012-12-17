module DnzHarvester
  module Xml
    class Base < DnzHarvester::Base

      self._base_urls[self.identifier] = []
      self._attribute_definitions[self.identifier] = {}

      class_attribute :_record_url_selector
      class_attribute :_record_selector
      class_attribute :_total_results

      class << self
        def records(options={})
          options.reverse_merge!(limit: nil)
          DnzHarvester::PaginatedCollection.new(self, self.pagination_options, options)
        end

        def fetch_records(url=nil)
          if sitemap?
            sitemap_records(url)
          else
            xml_records(url)
          end
        end

        def sitemap_records(url=nil)
          url_nodes = index_document(url).xpath(self._record_url_selector)
          url_nodes.map {|node| new(node.text) }
        end

        def xml_records(url=nil)
          xml_nodes = index_document(url).xpath(self._record_selector)
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

        def index_document(url=nil)
          doc = Nokogiri.parse(self.index_xml(url))
          doc.remove_namespaces!
          if pagination_options
            self._total_results ||= doc.xpath(self.pagination_options[:total_selector]).text.to_i
          end
          doc
        end

        def index_xml(url=nil)
          if base_urls.first.match(/^https?/)
            DnzHarvester::Utils.get(url || base_urls.first)
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