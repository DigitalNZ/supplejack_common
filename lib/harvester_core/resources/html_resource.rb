module HarvesterCore
  class HtmlResource < XmlResource
    
    def document
      @document ||= Nokogiri::HTML.parse(fetch)
    end
  end
end