# frozen_string_literal: true

module SupplejackCommon
  module Xml
    class Base < SupplejackCommon::Base
      include SupplejackCommon::XmlDslMethods
      include SupplejackCommon::XmlDataMethods
      include SupplejackCommon::XmlDocumentMethods
      include SupplejackCommon::Dsl::Sitemap

      clear_definitions

      class_attribute :_record_selector
      class_attribute :_record_format
      class_attribute :_total_results
      class_attribute :_document

      class << self
        def record_selector(xpath)
          self._record_selector = xpath
        end

        def next_page_token(next_page_token_location)
          _document.xpath(next_page_token_location, _namespaces).first&.text
        end

        def records(options = {})
          pagination_options = {}
          pagination_options[:job] = options[:job] if options[:job].present?
          pagination_options[:base_urls] = options[:base_urls] if options[:base_urls].present?
          pagination_options[:limit] = options[:limit] if options[:limit].present?
          pagination_options[:counter] = options[:counter] if options[:counter].present?

          options.reverse_merge!(limit: nil)
          klass = !!_sitemap_entry_selector ? SupplejackCommon::Sitemap::PaginatedCollection : SupplejackCommon::PaginatedCollection
          klass.new(self, pagination_options, options)
        end

        def fetch_records(url = nil)
          xml_records(url)
        end

        def record_format(format)
          self._record_format = format.to_sym
        end

        def clear_definitions
          super
          self._record_selector = nil
          self._total_results = nil
          self._record_format = nil
          self._document = nil
          self._pre_process_block = nil
        end

        def total_results(_total_selector)
          _total_results
        end
      end

      attr_accessor :original_xml

      def initialize(node, url = nil, from_raw = false)
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
          @url.gsub('http://', "http://#{self.class.basic_auth_credentials[:username]}:#{self.class.basic_auth_credentials[:password]}@")
        else
          @url
        end
      end

      def document
        @document ||= begin
          if @url
            response = SupplejackCommon::Request.get(url, _request_timeout, _throttle, _http_headers, _proxy)
            response = SupplejackCommon::Utils.add_html_tag(response) if format == :html
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
