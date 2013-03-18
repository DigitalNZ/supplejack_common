module HarvesterCore
  module Xml
    class Base < HarvesterCore::Base
      include HarvesterCore::XmlMethods

      self.clear_definitions

      class_attribute :_record_url_selector
      class_attribute :_record_selector
      class_attribute :_record_format
      class_attribute :_sitemap_format
      class_attribute :_total_results

      self._sitemap_format = :html

      class << self
        def records(options={})
          options.reverse_merge!(limit: nil)
          HarvesterCore::PaginatedCollection.new(self, self.pagination_options, options)
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

          if self._record_selector
            url_nodes.map do |node|
              document = sitemap_format_class.parse(HarvesterCore::Request.get(node.text))
              document.xpath(self._record_selector).map do |entry_node|
                new(entry_node)
              end
            end.flatten
          else
            url_nodes.map {|node| new(node.text) }
          end
        end

        def xml_records(url=nil)
          document = index_document(url)
          self._namespaces = document.namespaces
          xml_nodes = document.xpath(self._record_selector)
          xml_nodes.map {|node | new(node) }
        end

        def record_url_selector(xpath)
          self._record_url_selector = xpath
        end

        def record_format(format)
          self._record_format = format.to_sym
        end

        def record_selector(xpath)
          self._record_selector = xpath
        end

        def sitemap_format(format)
          self._sitemap_format = format.to_sym
        end

        def sitemap_format_class
          return Nokogiri::HTML unless [:xml, :html].include?(self._sitemap_format)
          "Nokogiri::#{self._sitemap_format.to_s.upcase}".constantize
        end

        def sitemap?
          self._record_url_selector.present?
        end

        def index_document(url=nil)
          xml = HarvesterCore::Utils.remove_default_namespace(self.index_xml(url))
          doc = Nokogiri::XML.parse(xml)
          if pagination_options
            self._total_results ||= doc.xpath(self.pagination_options[:total_selector]).text.to_i
          end
          doc
        end

        def index_xml(url=nil)
          if base_urls.first.match(/^https?/)
            HarvesterCore::Request.get(url || base_urls.first, self._throttle)
          elsif base_urls.first.match(/^file/)
            File.read(base_urls.first.gsub(/file:\//, ""))
          end
        end

        def clear_definitions
          super
          self._record_url_selector = nil
          self._record_selector = nil
          self._total_results = nil
          self._record_format = nil
        end
      end

      attr_accessor :original_xml

      def initialize(url_or_node, from_raw=false)
        if from_raw
          @original_xml = url_or_node
        else
          if url_or_node.is_a?(String)
            @url = url_or_node
          else
            @document = url_or_node
          end
        end

        super
      end

      def format
        return self.class._record_format if self.class._record_format.present?
        @url.present? ? :html : :xml
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
          if @url
            response = HarvesterCore::Request.get(self.url, self._throttle)
            response = HarvesterCore::Utils.remove_default_namespace(response) if format == :xml
            response = HarvesterCore::Utils.add_html_tag(response) if format == :html
          elsif @original_xml
            response = @original_xml
          end

          if format == :html
            Nokogiri::HTML.parse(response)
          else
            Nokogiri::XML.parse(response)
          end
        end
      end

    end
  end
end