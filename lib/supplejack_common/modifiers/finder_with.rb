module SupplejackCommon
  module Modifiers
    class FinderWith < AbstractModifier

      attr_reader :original_value, :regexp, :scope

      def initialize(original_value, regexp, scope=:first)
        @original_value, @regexp, @scope = original_value, regexp, scope
      end

      def modify
        finder_method = scope == :first ? :find : :find_all
        Array(original_value.send(finder_method) {|c| c.to_s.match(regexp) })
      end
    end
  end
end
