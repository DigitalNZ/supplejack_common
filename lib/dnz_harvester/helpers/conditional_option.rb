module DnzHarvester
  class ConditionalOption < AbstractOption

    def if_xpath
      if_conditions.keys.first
    end

    def if_values
      Array(if_conditions.values.first)
    end

    def if_conditions
      @if_conditions ||= options[:if] || {}
    end

    def matching_node
      @matching_node ||= nodes.detect {|node| if_values.include?(node.xpath(if_xpath).text) }
    end

    def value
      return nil unless matching_node
      @value ||= matching_node.xpath(options[:value]).text
    end
  end
end