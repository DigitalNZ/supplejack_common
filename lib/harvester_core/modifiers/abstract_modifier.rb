module HarvesterCore
  module Modifiers
    class AbstractModifier
      
      attr_reader :original_value

      def initialize(original_value)
        @original_value = original_value
      end

      def modify
        raise NotImplementedError.new("All subclasses of HarvesterCore::Modifiers::AbstractModifier must override #modify.")
      end

      def value
        AttributeValue.new(self.modify)
      end
    end
  end
end