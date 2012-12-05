module DnzHarvester
  class MappingOption < AbstractOption

    def mappings
      @mappings ||= options[:mappings] || {}
    end

    def nodes_text
      nodes.map(&:text).join
    end

    def value
      mappings.each do |regexp, substitution_value|
        return substitution_value if nodes_text.match(/#{regexp}/)
      end

      return nil
    end
  end
end