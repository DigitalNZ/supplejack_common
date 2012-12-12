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

      def strip_html(original_value)
        HtmlStripper.new(original_value).value
      end

      def truncate_value(original_value, length, omission="")
        ValueTruncator.new(original_value, length, omission).value
      end
    end
  end
end