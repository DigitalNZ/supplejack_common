module DnzHarvester
  class HtmlStripper
    include ActionView::Helpers::SanitizeHelper
      
    attr_reader :original_value

    def initialize(original_value)
      @original_value = original_value
    end

    def value
      if original_value.is_a?(Array)
        original_value.map {|v| v.is_a?(String) ? strip_tags(v) : v }
      elsif original_value.is_a?(String)
        strip_tags(original_value)
      else
        original_value
      end
    end
    
  end
end