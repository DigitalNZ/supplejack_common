module HarvesterCore
  class XmlResource < Resource
    include HarvesterCore::XmlDslMethods

    attr_reader :namespaces

    def initialize(url, options={})
      super
      @namespaces = options[:namespaces] || {}
    end
    
    def document
      @document ||= begin
        Nokogiri::XML.parse(fetch_document)
      end
    end

    def strategy_value(options)
      HarvesterCore::XpathOption.new(document, options, namespaces).value if options[:xpath]
    end
  end
end