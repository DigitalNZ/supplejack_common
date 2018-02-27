

module SupplejackCommon
  class XmlResource < Resource
    include SupplejackCommon::XmlDslMethods

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
      SupplejackCommon::XpathOption.new(document, options, self.class._namespaces).value if options[:xpath]
    end
  end
end