module DnzHarvester
  class ValueJoiner
      
    attr_reader :original_value, :joiner

    def initialize(original_value, joiner)
      @original_value, @joiner = original_value, joiner.to_s
    end

    def value
      standarized_value.join(joiner)
    end

    def standarized_value
      if original_value.is_a?(Array)
        original_value.map(&:strip)
      else
        original_value.to_s.split(joiner).map(&:strip)
      end
    end
    
  end
end