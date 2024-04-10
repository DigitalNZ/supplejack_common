# frozen_string_literal: true

module SupplejackCommon
  module Modifiers
    class AbstractModifier
      attr_reader :original_value

      def initialize(original_value)
        @original_value = original_value
      end

      def modify
        raise NotImplementedError,
              'All subclasses of SupplejackCommon::Modifiers::AbstractModifier must override #modify.'
      end

      def value
        AttributeValue.new(modify)
      end
    end
  end
end
