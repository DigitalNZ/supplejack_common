
# frozen_string_literal: true

module SupplejackCommon
  # AttributeBuilder
  class AttributeBuilder
    attr_reader :record, :attribute_name, :options, :errors

    def initialize(record, attribute_name, options)
      @record = record
      @attribute_name = attribute_name
      @options = options
      @errors = []
    end

    def transform
      value = SupplejackCommon::Utils.array(attribute_value)
      value = mapping_option(value, options[:mappings]) if options.key? :mappings
      value = split_option(value, options[:separator]) if options.key? :separator
      value = join_option(value, options[:join]) if options.key? :join
      value = strip_html_option(value)
      value = strip_whitespace_option(value)
      value = compact_whitespace(value)
      value = truncate_option(value, options[:truncate]) if options.key? :truncate
      value = parse_date_option(value, options[:date]) if options.key? :date
      value.uniq
    end

    def attribute_value
      return options[:default] if options.key? :default
      record.strategy_value(options)
    end

    def value
      if block = begin
                   options[:block]
                 rescue StandardError
                   nil
                 end
        begin
          record.attributes[attribute_name] = transform
          return evaluate_attribute_block(&block)
        rescue StandardError => e
          self.errors ||= []
          self.errors << "Error in the block: #{e.message}"
          return nil
        end
      else
        transform
      end
    end

    def evaluate_attribute_block(&block)
      block_result = record.instance_eval(&block)
      return transform if block_result.nil?

      block_result = strip_html_option(block_result)
      block_result = strip_whitespace_option(block_result)

      unless block_result.is_a?(SupplejackCommon::AttributeValue)
        block_result = SupplejackCommon::AttributeValue.new(block_result)
      end
      block_result.to_a
    end

    def split_option(original_value, separator)
      SupplejackCommon::Modifiers::Splitter.new(original_value,
                                                separator).modify
    end

    def join_option(original_value, joiner)
      SupplejackCommon::Modifiers::Joiner.new(original_value,
                                              joiner).modify
    end

    def strip_html_option(original_value)
      SupplejackCommon::Modifiers::HtmlStripper.new(original_value).modify
    end

    def strip_whitespace_option(original_value)
      SupplejackCommon::Modifiers::WhitespaceStripper.new(original_value).modify
    end

    def truncate_option(original_value, options)
      omission = '...'
      if options.is_a?(Hash)
        omission = options[:omission].to_s
        length = options[:length].to_i
      elsif options.is_a?(Integer)
        length = options
      end

      SupplejackCommon::Modifiers::Truncator.new(original_value,
                                                 length, omission).modify
    end

    def parse_date_option(original_value, date_format)
      SupplejackCommon::Modifiers::DateParser.new(original_value,
                                                  date_format).modify
    end

    def mapping_option(original_value, mappings = {})
      SupplejackCommon::Modifiers::Mapper.new(original_value,
                                              mappings).modify
    end

    def compact_whitespace(original_value)
      SupplejackCommon::Modifiers::WhitespaceCompactor.new(original_value).modify
    end
  end
end
