module SupplejackCommon
  module Modifiers
    class RangeSelector < AbstractModifier

      def initialize(original_value, start_range, end_range = nil)
        @original_value = original_value
        @start_range = start_range
        @end_range = end_range
      end

      def start_range
        return 0 if @start_range == :first
        return -1 if @start_range == :last
        return @start_range-1 if @start_range > 0
        @start_range
      end

      def end_range
        return -1 if @end_range == :last
        return @end_range-1 if @end_range && @end_range > 0
        @end_range
      end

      def modify
        if end_range
          original_value[start_range..end_range]
        else
          Array(original_value[start_range])
        end
      end
    end
  end
end
