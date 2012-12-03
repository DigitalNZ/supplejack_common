module DnzHarvester
  module Filters
    class Transformer

      attr_reader :record, :regexp, :substitute_value

      def initialize(record, regexp, substitute_value)
        @record, @regexp, @substitute_value = record, regexp, substitute_value
      end

      def contents(attribute_name)
        values = record.original_attributes[attribute_name.to_sym]
        values = *values
      end

      def within(attribute_name)
        values = contents(attribute_name).map do |value|
          value.gsub(regexp, substitute_value) if value.match(regexp)
        end.compact

        values = values.first if values.size == 1
        values
      end
    end
  end
end
