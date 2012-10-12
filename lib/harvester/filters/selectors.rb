module Harvester
  module Filters
    class Selector
      attr_reader :record, :regexp, :scope

      def initialize(record, regexp, scope=:first)
        @record, @regexp, @scope = record, regexp, scope
      end

      def contents(attribute_name)
        contents = *record.attributes[attribute_name.to_sym]
      end
    end

    class WithSelector < Selector
      def within(attribute_name)
        result = contents(attribute_name).find_all {|c| c.to_s.match(regexp) }
        result = result.first if scope == :first
        result
      end
    end

    class WithoutSelector < Selector
      def within(attribute_name)
        result = contents(attribute_name).reject {|c| c.to_s.match(regexp) }
        result = result.first if scope == :first
        result
      end
    end
  end
end