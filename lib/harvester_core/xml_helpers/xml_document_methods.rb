module HarvesterCore
  module XmlDocumentMethods
    extend ::ActiveSupport::Concern
		
		module ClassMethods

	    def index_document(url=nil)
	      xml = HarvesterCore::Utils.remove_default_namespace(self.index_xml(url))
	      doc = Nokogiri::XML.parse(xml)
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
        self._namespaces = document.namespaces
        xml_nodes = document.xpath(self._record_selector)
        xml_nodes.map {|node | new(node) }
      end
	  end
  end
end