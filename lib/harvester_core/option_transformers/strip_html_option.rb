require 'action_controller/vendor/html-scanner'

module HarvesterCore
  module OptionTransformers
    class StripHtmlOption        
      attr_reader :original_value

      def initialize(original_value)
        @original_value = Array(original_value)
      end

      def value
        original_value.map do |v|
          v.is_a?(String) ? strip_tags(v) : v
        end
      end

      def self.full_sanitizer
        @full_sanitizer ||= HTML::FullSanitizer.new
      end

      def strip_tags(html)
        self.class.full_sanitizer.sanitize(html)
      end
      
    end
  end
end