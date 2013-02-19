module HarvesterCore
  module OptionTransformers
    class SplitOption
        
      attr_reader :original_value, :separator

      def initialize(original_value, separator)
        @original_value = Array(original_value)
        @separator = separator
      end

      def value
        original_value.map {|v| v.split(separator)}.flatten
      end
      
    end
  end
end