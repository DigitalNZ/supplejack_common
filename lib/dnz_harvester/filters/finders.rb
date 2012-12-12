module DnzHarvester
  module Filters
    module Finders
      extend ::ActiveSupport::Concern

      def find_with(regexp)
        WithSelector.new(self, regexp, :first)
      end

      def find_all_with(regexp)
        WithSelector.new(self, regexp, :all)
      end

      def find_without(regexp)
        WithoutSelector.new(self, regexp, :first)
      end

      def find_all_without(regexp)
        WithoutSelector.new(self, regexp, :all)
      end

      def find_and_replace(regex, substitute_value)
        FindReplacer.new(self, regex, substitute_value)
      end

      def select(start_range, end_range=nil)
        RangeSelector.new(self, start_range, end_range)
      end
    end
  end
end