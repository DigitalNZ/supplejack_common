module HarvesterCore
  module Xml
    class Base < HarvesterCore::Base
      include HarvesterCore::XmlDslMethods
      include HarvesterCore::XmlDataMethods
      include HarvesterCore::XmlDocumentMethods
      include HarvesterCore::Dsl::Sitemap

      self.clear_definitions
      
      class_attribute :_record_selector
      class_attribute :_record_format
      class_attribute :_total_results

      class << self
        def records(options={})
          options.reverse_merge!(limit: nil)
          klass = !!self._sitemap_entry_selector ? HarvesterCore::Sitemap::PaginatedCollection : HarvesterCore::PaginatedCollection
          klass.new(self, self.pagination_options, options)
        end

        def fetch_records(url=nil)
          xml_records(url)
        end

        def record_format(format)
          self._record_format = format.to_sym
        end

        def record_selector(xpath)
          self._record_selector = xpath
        end

        def clear_definitions
          super
          self._record_selector = nil
          self._total_results = nil
          self._record_format = nil
        end
      end

      attr_accessor :original_xml

      def initialize(node, url=nil, from_raw=false)
        if from_raw
          @original_xml = node
        else
          @url = url if url.present?
          @document = node if node.present?
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