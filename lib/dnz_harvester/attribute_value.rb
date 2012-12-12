module DnzHarvester
  class AttributeValue

    attr_reader :original_value
    
    def initialize(original_value)
      @original_value = Array(original_value)
    end

    def find_with(regexp)
      WithSelector.new(original_value, regexp, :first).value
    end

    def find_all_with(regexp)
      WithSelector.new(original_value, regexp, :all).value
    end

    def find_without(regexp)
      WithoutSelector.new(original_value, regexp, :first).value
    end

    def find_all_without(regexp)
      WithoutSelector.new(original_value, regexp, :all).value
    end

    def find_and_replace(regex, substitute_value)
      FindReplacer.new(original_value, regex, substitute_value).value
    end

    def select(start_range, end_range=nil)
      RangeSelector.new(original_value, start_range, end_range).value
    end
  end
end