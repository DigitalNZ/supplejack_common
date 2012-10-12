module Harvester
  module Filters
    class Transformer

      attr_reader :record, :regexp, :substitute_value

      def initialize(record, regexp, substitute_value)
        @record, @regexp, @substitute_value = record, regexp, substitute_value
      end

      def contents(attribute_name)
        values = record.attributes[attribute_name.to_sym]
        @is_array = values.is_a?(Array)
        values = *values
      end

      def within(attribute_name)
        values = contents(attribute_name).map do |value|
          value.gsub(regexp, substitute_value)
        end

        values = values.first unless @is_array
        values
      end
    end
  end
end
