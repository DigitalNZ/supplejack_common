module DnzHarvester
  module Filters
    module AttributeValues

      def contents(attribute_name)
        Array(record.original_attributes[attribute_name.to_sym])
      end
    end

  end
end