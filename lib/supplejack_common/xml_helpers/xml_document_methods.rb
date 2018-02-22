

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
          document = parse_document(file)
          self._document = document
          xml_nodes += document.xpath(self._record_selector, self._namespaces).map {|node| new(node, url) }
          if pagination_options&.include?(:total_selector)
            if self.pagination_options[:total_selector].start_with?("/")
              self._total_results ||= document.xpath(self.pagination_options[:total_selector]).text.to_i
            else
              self._total_results ||= document.xpath(self.pagination_options[:total_selector]).to_i
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
      def with_each_file(url, &block)
        if url.match(/^https?/)
          yield SupplejackCommon::Request.get(url,self._request_timeout, self._throttle, self._http_headers)
        elsif url.match(/^file/)
          url = url.gsub(/file:\/\//, "")

          if url.match(/.tar.gz$/) or url.match(/.tgz$/)
            tar_extract = Gem::Package::TarReader.new(Zlib::GzipReader.open(url))
            tar_extract.rewind
            tar_extract.each do |entry|
              if entry.file?
                yield entry.read
              end
            end
          else
            yield File.read(url)
          end
        end
      end

      def parse_document(xml)
        if self._record_format == :html
          Nokogiri::HTML.parse(xml)
        else
          Nokogiri::XML.parse(xml)
        end
      end

	  end
  end
end
