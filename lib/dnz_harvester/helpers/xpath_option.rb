module DnzHarvester
  class XpathOption < AbstractOption

    def value
      return nodes if options[:object]

      if nodes.is_a?(Array)
        nodes.map(&:text)
      else
        nodes.text
      end
    end
  end
end