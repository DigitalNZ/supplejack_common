module DnzHarvester
  class AbstractOption
      
    attr_reader :document, :options

    def initialize(document, options)
      @document = document
      @options = options
    end

    def nodes
      return [] unless options[:xpath].present?
      xpath_expressions = Array(options[:xpath])
      @nodes = []

      xpath_expressions.each do |xpath|
        @nodes += document.xpath("#{xpath_value(xpath)}")
      end

      @nodes
    end

    def xpath_value(xpath)
      xpath = ".#{xpath}" if document.is_a?(Nokogiri::XML::NodeSet) || document.is_a?(Nokogiri::XML::Element)
      xpath
    end
  end
end