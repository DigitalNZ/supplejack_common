module HarvesterCore
  class XmlResource < Resource
    include HarvesterCore::XmlDslMethods

    def initialize(url, options={})
      super
      self.class.namespaces(options[:namespaces] || {})
    end
    
    def document
      @document ||= begin
        Nokogiri::XML.parse(fetch_document)
      end
    end

    def strategy_value(options)
      HarvesterCore::XpathOption.new(document, options, self.class._namespaces).value if options[:xpath]
    end
  end
end