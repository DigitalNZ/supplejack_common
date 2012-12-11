module DnzHarvester
  module Filters
    class RangeSelector
      include DnzHarvester::Filters::AttributeValues

      attr_reader :record

      def initialize(record, start_range, end_range=nil)
        @record = record
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

      def within(attribute_name)
        if end_range
          contents(attribute_name)[start_range..end_range]
        else
          contents(attribute_name)[start_range]
        end
      end
    end
  end
end
