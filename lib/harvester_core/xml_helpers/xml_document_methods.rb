module HarvesterCore
  module XmlDocumentMethods
    extend ::ActiveSupport::Concern

    included do
      class_attribute :_record_format
    end
		
		module ClassMethods

	    def index_document(url=nil)
        xml = self.index_xml(url)
        if self._record_format == :html
          doc = Nokogiri::HTML.parse(xml)
        else
          doc = Nokogiri::XML.parse(xml)
        end
	      if pagination_options
	        self._total_results ||= doc.xpath(self.pagination_options[:total_selector]).text.to_i
	      end
	      doc
	    end

	    def index_xml(url=nil)
	      url ||= base_urls.first

	      if url.match(/^https?/)
	      	HarvesterCore::Request.get(url, self._throttle)
	      elsif url.match(/^file/)
	        File.read(url.gsub(/file:\//, ""))
	      end
	    end

      def xml_records(url=nil)
        document = index_document(url)
        xml_nodes = document.xpath(self._record_selector, self._namespaces)
        xml_nodes.map {|node| new(node, url) }
      end
	  end
  end
end