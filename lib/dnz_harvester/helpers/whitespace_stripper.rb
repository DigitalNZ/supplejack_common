module DnzHarvester
  class WhitespaceStripper
      
    attr_reader :original_value

    def initialize(original_value)
      @original_value = original_value
    end

    def value
      if original_value.is_a?(Array)
        original_value.map {|v| v.is_a?(String) ? v.strip : v }
      elsif original_value.is_a?(String)
        original_value.strip
      else
        original_value
      end
    end
    
  end
end