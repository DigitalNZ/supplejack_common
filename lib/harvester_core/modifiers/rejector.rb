module HarvesterCore
  module Modifiers
    class Rejector < AbstractModifier
        
      attr_reader :original_value, :regex

      def initialize(original_value, regex)
        @original_value = Array(original_value)
        @regex = regex.to_s
      end

      def modify
        original_value.reject_if { |v| v.match }
      end
      
    end
  end
end