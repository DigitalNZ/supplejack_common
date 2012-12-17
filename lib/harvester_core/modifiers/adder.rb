module HarvesterCore
  module Modifiers
    class Adder < AbstractModifier

      attr_reader :new_value

      def initialize(original_value, new_value)
        @original_value = original_value
        @new_value = new_value
      end

      def modify
        original_value + Array(new_value)
      end
    end
  end
end