module DnzHarvester
  module Filters
    class FindReplacer
      include DnzHarvester::Filters::AttributeValues

      attr_reader :record, :regexp, :substitute_value

      def initialize(record, regexp, substitute_value)
        @record = record
        @regexp = Array(regexp)
        @substitute_value = Array(substitute_value)
      end

      def within(attribute_name)
        values = contents(attribute_name).map do |value|
          replaced = nil
          regexp.each_with_index do |r, index|
            replaced = value.gsub!(r, substitute_value[index]) if substitute_value[index]
          end
          replaced.present? ? value : nil
        end.compact

        values = values.first if values.size == 1
        values
      end
    end
  end
end
