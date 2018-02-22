module SupplejackCommon
  module Modifiers
    class FinderWithout < AbstractModifier

      attr_reader :original_value, :regexp, :scope

      def initialize(original_value, regexp, scope=:first)
        @original_value, @regexp, @scope = original_value, regexp, scope
      end

      def modify
        new_values = original_value.reject {|c| c.to_s.match(regexp) }
        new_values = [new_values.first] if scope == :first
        new_values
      end
    end
  end
end
