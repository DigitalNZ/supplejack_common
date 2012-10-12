module Harvester
  module Filters
    module Modifiers
      extend ActiveSupport::Concern

      def add(new_value, options={})
        existing_values = *attribute(options[:to])
        IfCondition.new(self, new_value, existing_values)
      end

      private

      def attribute(field)
        self.attributes[field.to_sym]
      end
    end
  end
end