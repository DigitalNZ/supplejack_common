module DnzHarvester
  module Helpers
    module ValueTransformers
      
      def split_value(original_value, separator)
        ValueSeparator.new(original_value, separator).value
      end

      def join_value(original_value, joiner)
        ValueJoiner.new(original_value, joiner).value
      end

      def strip_whitespace(original_value)
        WhitespaceStripper.new(original_value).value
      end
    end
  end
end