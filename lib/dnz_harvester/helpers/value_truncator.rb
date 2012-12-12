module DnzHarvester
  class ValueTruncator
    
    attr_reader :original_value, :length, :omission

    def initialize(original_value, length, omission="")
      @original_value = original_value.to_s
      @length = length.to_i
      @omission = omission
    end

    def value
      if original_value.is_a?(String)
        original_value.truncate(length, omission: omission)
      else
        original_value
      end
    end
  end
end