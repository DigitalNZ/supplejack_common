# frozen_string_literal: true

module SupplejackCommon
  module Modifiers
    class Truncator < AbstractModifier
      attr_reader :original_value, :length, :omission

      def initialize(original_value, length, omission = '...')
        @original_value = original_value
        @length = length.to_i
        @omission = omission.to_s
      end

      def modify
        original_value.map do |value|
          value.is_a?(String) ? value.truncate(length, omission:) : value
        end
      end
    end
  end
end
