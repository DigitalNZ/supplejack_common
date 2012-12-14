module DnzHarvester
  class AttributeValue

    attr_reader :original_value
    
    def initialize(original_value)
      @original_value = Array(original_value)
      @original_value = @original_value.delete_if(&:blank?)
    end

    def to_a
      original_value
    end

    def present?
      original_value.present?
    end

    def find_with(regexp)
      DnzHarvester::Modifiers::FinderWith.new(original_value, regexp, :first).value
    end

    def find_all_with(regexp)
      DnzHarvester::Modifiers::FinderWith.new(original_value, regexp, :all).value
    end

    def find_without(regexp)
      DnzHarvester::Modifiers::FinderWithout.new(original_value, regexp, :first).value
    end

    def find_all_without(regexp)
      DnzHarvester::Modifiers::FinderWithout.new(original_value, regexp, :all).value
    end

    def find_and_replace(replacement_rules)
      DnzHarvester::Modifiers::FindReplacer.new(original_value, replacement_rules).value
    end

    def select(start_range, end_range=nil)
      DnzHarvester::Modifiers::RangeSelector.new(original_value, start_range, end_range).value
    end

    def add(new_value)
      DnzHarvester::Modifiers::Adder.new(original_value, new_value).value
    end
  end
end