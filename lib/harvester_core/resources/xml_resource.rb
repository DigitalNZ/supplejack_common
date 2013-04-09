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
        xml = HarvesterCore::Utils.remove_default_namespace(fetch_document)
        Nokogiri::XML.parse(xml)
      end
    end

    def strategy_value(options)
      return HarvesterCore::ConditionalOption.new(document, options, namespaces).value if options[:xpath] && options[:if]
      return HarvesterCore::XpathOption.new(document, options, namespaces).value if options[:xpath]
    end
  end
end