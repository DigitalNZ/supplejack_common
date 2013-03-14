module HarvesterCore
  
  class AttributeBuilder

    attr_reader :record, :document, :options, :errors, :attribute_name

    def initialize(record, attribute_name, options)
      @record = record
      @attribute_name = attribute_name
      @document = record.document
      @options = options
      @errors = []
    end

    def transform
      value = HarvesterCore::Utils.array(attribute_value)
      value = mapping_option(value, options[:mappings]) if options[:mappings]
      value = split_option(value, options[:separator]) if options[:separator]
      value = join_option(value, options[:join]) if options[:join]
      value = strip_html_option(value)
      value = strip_whitespace_option(value)
      value = truncate_option(value, options[:truncate]) if options[:truncate]
      value = parse_date_option(value, options[:date]) if options[:date]
      value.uniq
    end

    def attribute_value
      return options[:default] if options[:default]
      return record.strategy_value(options, document)
    end

    def value
      if block = options[:block] rescue nil
        begin
          record.attributes[attribute_name] = transform
          evaluate_attribute_block(&block)
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
      if block_result.is_a?(HarvesterCore::AttributeValue)
        block_result.to_a
      else
        block_result
      end
    end

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