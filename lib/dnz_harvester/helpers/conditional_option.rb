module DnzHarvester
  class ConditionalOption
      
    attr_reader :document, :options

    def initialize(document, options)
      @document = document
      @options = options
    end

    def nodes
      return [] unless options[:xpath].present?
      @nodes ||= document.xpath("//#{options[:xpath]}")
    end

    def if_xpath
      if_conditions.keys.first
    end

    def if_value
      if_conditions.values.first
    end

    def if_conditions
      @if_conditions ||= options[:if] || {}
    end

    def matching_node
      @matching_node ||= nodes.detect {|node| node.xpath(if_xpath).text == if_value }
    end

    def value
      @value ||= matching_node.xpath(options[:value]).text
    end
  end
end