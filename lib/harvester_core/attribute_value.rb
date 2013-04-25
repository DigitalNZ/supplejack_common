module HarvesterCore
  class AttributeValue

    attr_reader :original_value
    
    def initialize(original_value)
      @original_value = Array(original_value)
      @original_value = @original_value.delete_if { |v| v == "" }
      @original_value = self.class.deep_clone(@original_value)
    end

    def self.deep_clone(original_value)
      original_value.map { |v| v.duplicable? ? v.dup : v }.uniq
    end

    def to_a
      original_value
    end

    def first
      original_value.first
    end

    def present?
      original_value.present?
    end

    def +(attribute_value)
      attribute_value = attribute_value.original_value if attribute_value.is_a?(AttributeValue)
      self.class.new(self.original_value + Array(attribute_value).uniq)
    end

    def includes?(value)
      if value.is_a?(Regexp)
        !!original_value.detect {|v| v.match(value) }
      else
        original_value.include?(value)
      end
    end

    alias_method  :include?, :includes?

    def find_with(regexp)
      HarvesterCore::Modifiers::FinderWith.new(original_value, regexp, :first).value
    end

    def find_all_with(regexp)
      HarvesterCore::Modifiers::FinderWith.new(original_value, regexp, :all).value
    end

    def find_without(regexp)
      HarvesterCore::Modifiers::FinderWithout.new(original_value, regexp, :first).value
    end

    def find_all_without(regexp)
      HarvesterCore::Modifiers::FinderWithout.new(original_value, regexp, :all).value
    end

    def mapping(replacement_rules)
      HarvesterCore::Modifiers::Mapper.new(original_value, replacement_rules).value
    end

    def select(start_range, end_range=nil)
      HarvesterCore::Modifiers::RangeSelector.new(original_value, start_range, end_range).value
    end

    def add(new_value)
      HarvesterCore::Modifiers::Adder.new(original_value, new_value).value
    end

    def split(split_value)
      HarvesterCore::Modifiers::Splitter.new(original_value, split_value).value
    end

    def compact_whitespace
      HarvesterCore::Modifiers::WhitespaceStripper.new(original_value).value
    end

    def truncate(length, omission="...")
      HarvesterCore::Modifiers::Truncator.new(original_value, length, omission).value
    end

    def to_date(format=nil)
      HarvesterCore::Modifiers::DateParser.new(original_value, format).value
    end

    def downcase
      self.class.new(original_value.map(&:downcase))
    end
  end
end