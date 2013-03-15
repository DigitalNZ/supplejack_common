module HarvesterCore
  class AbstractOption
      
    attr_reader :document, :options, :namespace_definitions

    def initialize(document, options, namespace_definitions={})
      @document = document
      @options = options
      @namespace_definitions = namespace_definitions || {}
    end

    def namespace
      keys = Array(options[:namespaces]).map(&:to_sym)
      return nil if keys.empty?
      Hash[keys.map {|namespace| [namespace, namespace_definitions[namespace]]}]
    end

    def nodes
      return [] unless options[:xpath].present?
      xpath_expressions = Array(options[:xpath])
      @nodes = []

      xpath_expressions.each do |xpath|
        @nodes += document.xpath("#{xpath_value(xpath)}", namespace)
      end

      @nodes
    end

    def xpath_value(xpath)
      xpath = ".#{xpath}" if document.is_a?(Nokogiri::XML::NodeSet) || document.is_a?(Nokogiri::XML::Element)
      xpath
    end
  end
end