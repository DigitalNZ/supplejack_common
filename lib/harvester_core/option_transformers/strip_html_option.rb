module HarvesterCore
  module OptionTransformers
    class StripHtmlOption
      include ActionView::Helpers::SanitizeHelper
        
      attr_reader :original_value

      def initialize(original_value)
        @original_value = Array(original_value)
      end

      def value
        original_value.map do |v|
          v.is_a?(String) ? strip_tags(v) : v
        end
      end
      
    end
  end
end