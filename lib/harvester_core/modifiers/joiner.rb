module HarvesterCore
  module Modifiers
    class Joiner < AbstractModifier
        
      attr_reader :original_value, :joiner

      def initialize(original_value, joiner)
        @original_value = original_value
        @joiner = joiner.to_s
      end

      def modify
        [original_value.join(joiner)]
      end
      
    end
  end
end