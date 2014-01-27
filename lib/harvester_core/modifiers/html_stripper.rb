require 'action_controller/vendor/html-scanner'

module HarvesterCore
  module Modifiers
    class HtmlStripper < AbstractModifier       
      attr_reader :original_value

      def initialize(original_value)
        @original_value = Array(original_value)
      end

      def modify
        original_value.map do |v|
          v.is_a?(String) ? strip_tags(v) : v
        end
      end

      def self.full_sanitizer
        @full_sanitizer ||= HTML::FullSanitizer.new
      end

      def strip_tags(html)
        html = validate_encoding(html)
        self.class.full_sanitizer.sanitize(html)
      end

      def validate_encoding(html)
        return html.dup.force_encoding('UTF-8').encode('UTF-16', invalid: :replace, replace: '').encode('UTF-8')
      end

    end
  end
end