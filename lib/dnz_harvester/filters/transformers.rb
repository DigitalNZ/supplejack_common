module DnzHarvester
  module Filters
    class Transformer
      include DnzHarvester::Filters::AttributeValues

      attr_reader :record, :regexp, :substitute_value

      def initialize(record, regexp, substitute_value)
        @record, @regexp, @substitute_value = record, regexp, substitute_value
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
