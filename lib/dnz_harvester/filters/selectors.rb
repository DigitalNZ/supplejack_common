module DnzHarvester
  module Filters
    class Selector
      attr_reader :record, :regexp, :scope

      def initialize(record, regexp, scope=:first)
        @record, @regexp, @scope = record, regexp, scope
      end

      def contents(attribute_name)
        contents = *record.original_attributes[attribute_name.to_sym]
      end

      def selected_values(attribute_name)
        raise NotImplementedError.new("All subclasses of DnzHarvester::Filters::Selector must override #selected_values.")
      end

      def within(attribute_name)
        values = selected_values(attribute_name)
        values = values.first if values.is_a?(Array) && scope == :first
        values
      end
    end

    class WithSelector < Selector
      def selected_values(attribute_name)
        contents(attribute_name).find_all {|c| c.to_s.match(regexp) }
      end
    end

    class WithoutSelector < Selector
      def selected_values(attribute_name)
        contents(attribute_name).reject {|c| c.to_s.match(regexp) }
      end
    end
  end
end