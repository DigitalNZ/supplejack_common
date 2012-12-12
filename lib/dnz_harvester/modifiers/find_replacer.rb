module DnzHarvester
  module Modifiers
    class FindReplacer < AbstractModifier
      attr_reader :regexp, :substitute_value

      def initialize(original_value, regexp, substitute_value)
        @original_value = original_value
        @regexp = Array(regexp)
        @substitute_value = Array(substitute_value)
      end

      def modify
        values = original_value.map do |value|
          replaced = nil
          regexp.each_with_index do |r, index|
            replaced = value.gsub!(r, substitute_value[index]) if substitute_value[index]
          end
          replaced.present? ? value : nil
        end.compact

        values
      end
    end
  end
end