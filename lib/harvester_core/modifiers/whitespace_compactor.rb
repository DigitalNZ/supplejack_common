module HarvesterCore
  module Modifiers
    class WhitespaceCompactor < AbstractModifier
        
      attr_reader :original_value

      def initialize(original_value)
        @original_value = Array(original_value)
      end

      def modify
        original_value.map do |v|
          v.is_a?(String) ? v.gsub(/\s+/,' ') : v
        end
      end
      
    end
  end
end