# frozen_string_literal: true

require 'rubygems/package'

module SupplejackCommon
  module XmlDocumentMethods
    extend ::ActiveSupport::Concern

    included do
      class_attribute :_record_format
    end

    module ClassMethods
      def xml_records(url)
        xml_nodes = []
        with_each_file(url) do |file|
          file = _pre_process_block.call(file) if _pre_process_block
          document = parse_document(file)
          self._document = document
          xml_nodes += document.xpath(_record_selector, _namespaces).map { |node| new(node, url) }
          if pagination_options&.include?(:total_selector)
            self._total_results ||= if pagination_options[:total_selector].start_with?('/')
                                      document.xpath(pagination_options[:total_selector]).text.to_i
                                    else
                                      document.xpath(pagination_options[:total_selector]).to_i
                                    end
          end
        end
        xml_nodes
      end

      private

      # This yields to the block each file at the given url
      # For single xml files and external urls, this will only be one file
      # For tar.gz this will yield once for each file in the tar
      #
      def with_each_file(url)
        if url =~ /^https?/
          yield SupplejackCommon::Request.get(url, _request_timeout, _throttle, _http_headers, _proxy)
        elsif url =~ /^file/
          url = url.gsub(%r{file://}, '')

          if url.match(/.tar.gz$/) || url.match(/.tgz$/)
            tar_extract = Gem::Package::TarReader.new(Zlib::GzipReader.open(url))
            tar_extract.rewind
            tar_extract.each do |entry|
              yield entry.read if entry.file?
            end
          else
            yield File.read(url)
          end
        end
      end

      def parse_document(xml)
        if _record_format == :html
          Nokogiri::HTML.parse(xml)
        else
          Nokogiri::XML.parse(xml)
        end
      end
    end
  end
end
