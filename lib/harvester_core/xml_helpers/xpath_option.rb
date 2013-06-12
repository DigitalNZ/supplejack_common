module HarvesterCore
  class XpathOption
    attr_reader :document, :options, :namespace_definitions

    def initialize(document, options, namespace_definitions={})
      @document = document
      @options = options
      @namespace_definitions = namespace_definitions || {}
    end

    def value
      return nodes if options[:object]

      if nodes.is_a?(Array)
        nodes.map(&:text)
      else
        nodes.text
      end
    end

    private

    def nodes
      return [] unless options[:xpath].present?
      xpath_expressions = Array(options[:xpath])
      @nodes = []

      xpath_expressions.each do |xpath|
        @nodes += document.xpath("#{xpath_value(xpath)}", namespace_definitions)
      end

      @nodes
    end

    def xpath_value(xpath)
      xpath = ".#{xpath}" if document.is_a?(Nokogiri::XML::NodeSet) || document.is_a?(Nokogiri::XML::Element)
      xpath
    end
  end
end