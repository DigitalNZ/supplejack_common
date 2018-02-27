

module SupplejackCommon
  class HtmlResource < XmlResource
    
    def document
      @document ||= Nokogiri::HTML.parse(fetch_document)
    end
  end
end