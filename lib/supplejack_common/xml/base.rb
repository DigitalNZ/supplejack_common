# The Supplejack Common code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# See https://github.com/DigitalNZ/supplejack for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs.
# http://digitalnz.org/supplejack

module SupplejackCommon
  module Xml
    class Base < SupplejackCommon::Base
      include SupplejackCommon::XmlDslMethods
      include SupplejackCommon::XmlDataMethods
      include SupplejackCommon::XmlDocumentMethods
      include SupplejackCommon::Dsl::Sitemap

      self.clear_definitions

      class_attribute :_record_selector
      class_attribute :_record_format
      class_attribute :_total_results
      class_attribute :_document

      class << self
        def record_selector(xpath)
          self._record_selector = xpath
        end

        def next_page_token(next_page_token_location)
          _document.xpath(next_page_token_location, self._namespaces).first.text
        end

        def records(options={})
          options.reverse_merge!(limit: nil)
          klass = !!self._sitemap_entry_selector ? SupplejackCommon::Sitemap::PaginatedCollection : SupplejackCommon::PaginatedCollection
          klass.new(self, self.pagination_options, options)
        end

        def fetch_records(url=nil)
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
        end

        def total_results(_total_selector)
          self._total_results
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
            response = SupplejackCommon::Request.get(self.url, self._request_timeout, self._throttle, self._http_headers)
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
