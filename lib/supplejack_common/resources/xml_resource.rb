# frozen_string_literal: true

module SupplejackCommon
  class XmlResource < Resource
    include SupplejackCommon::XmlDslMethods

    def initialize(url, options = {})
      super
      self.class.namespaces(options[:namespaces] || {})
    end

    def document
      @document ||= Nokogiri::XML.parse(fetch_document)
    end

    def strategy_value(options)
      SupplejackCommon::XpathOption.new(document, options, self.class._namespaces).value if options[:xpath]
    end
  end
end
