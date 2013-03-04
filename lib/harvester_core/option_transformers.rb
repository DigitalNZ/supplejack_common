module HarvesterCore
  module OptionTransformers
    extend ::ActiveSupport::Concern

    def split_option(original_value, separator)
      HarvesterCore::Modifiers::Splitter.new(original_value, separator).modify
    end

    def join_option(original_value, joiner)
      HarvesterCore::Modifiers::Joiner.new(original_value, joiner).modify
    end

    def strip_html_option(original_value)
      HarvesterCore::Modifiers::HtmlStripper.new(original_value).modify
    end

    def strip_whitespace_option(original_value)
      HarvesterCore::Modifiers::WhitespaceStripper.new(original_value).modify
    end

    def truncate_option(original_value, options)
      omission = "..."
      if options.is_a?(Hash)
        omission = options[:omission].to_s
        length = options[:length].to_i
      elsif options.is_a?(Integer)
        length = options
      end

      HarvesterCore::Modifiers::Truncator.new(original_value, length, omission).modify
    end

    def parse_date_option(original_value, date_format)
      HarvesterCore::Modifiers::DateParser.new(original_value, date_format).modify
    end

    def mapping_option(original_value, mappings={})
      HarvesterCore::Modifiers::Mapper.new(original_value, mappings).modify
    end

  end
end