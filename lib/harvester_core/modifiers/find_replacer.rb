module HarvesterCore
  module Modifiers
    class FindReplacer < AbstractModifier
      attr_reader :regexp, :replacement_rules

      def initialize(original_value, replacement_rules={})
        @original_value = original_value.map(&:dup)
        @replacement_rules = replacement_rules
      end

      def modify
        values = original_value.map do |value|
          replaced = nil
          replacement_rules.each do |regexp, substitute_value|
            replaced = value.gsub!(regexp, substitute_value)
          end
          replaced.present? ? value : nil
        end.compact

        values
      end
    end
  end
end