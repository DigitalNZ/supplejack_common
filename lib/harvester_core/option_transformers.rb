require "harvester_core/option_transformers/split_option"
require "harvester_core/option_transformers/join_option"
require "harvester_core/option_transformers/strip_html_option"
require "harvester_core/option_transformers/strip_whitespace_option"
require "harvester_core/option_transformers/truncate_option"

module HarvesterCore
  module OptionTransformers
    extend ::ActiveSupport::Concern

    def split_option(original_value, separator)
      SplitOption.new(original_value, separator).value
    end

    def join_option(original_value, joiner)
      JoinOption.new(original_value, joiner).value
    end

    def strip_html_option(original_value)
      StripHtmlOption.new(original_value).value
    end

    def strip_whitespace_option(original_value)
      StripWhitespaceOption.new(original_value).value
    end

    def truncate_option(original_value, options)
      omission = "..."
      if options.is_a?(Hash)
        omission = options[:omission].to_s
        length = options[:length].to_i
      elsif options.is_a?(Integer)
        length = options
      end

      TruncateOption.new(original_value, length, omission).value
    end

    def parse_date_option(original_value, date_format)
      HarvesterCore::Modifiers::DateParser.new(original_value, date_format).modify
    end

    def mapping_option(original_value, mappings={})
      HarvesterCore::Modifiers::Mapper.new(original_value, mappings).modify
    end

  end
end