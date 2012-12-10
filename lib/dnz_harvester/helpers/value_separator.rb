module DnzHarvester
  class ValueSeparator
      
    attr_reader :original_value, :separator

    def initialize(original_value, separator)
      @original_value, @separator = original_value, separator.to_s
    end

    def value
      standarized_value.split(separator).map(&:strip)
    end

    def standarized_value
      if original_value.is_a?(Array)
        original_value.join(separator)
      else
        original_value
      end
    end
    
  end

  module ValueSeparatorHelper
    def split_value(original_value, separator)
      ValueSeparator.new(original_value, separator).value
    end
  end
end