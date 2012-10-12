module Harvester
  module Filters
    module Finders
      extend ActiveSupport::Concern

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

      def last(field)
        value = attribute(field)
        Utils.array(value).last
      end

      def find_and_replace(regex, substitute_value)
        Transformer.new(self, regex, substitute_value)
      end

      private

      def attribute(field)
        self.attributes[field.to_sym]
      end
    end
  end
end