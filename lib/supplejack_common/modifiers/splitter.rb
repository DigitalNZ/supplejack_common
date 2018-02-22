module SupplejackCommon
  module Modifiers
    class Splitter < AbstractModifier

      attr_reader :original_value, :split_value

      def initialize(original_value, split_value)
        @original_value, @split_value = original_value, split_value
      end

      def modify
        original_value.map do |value|
          value.split(split_value)
        end.flatten
      end
    end
  end
end