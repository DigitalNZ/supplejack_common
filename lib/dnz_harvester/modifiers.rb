require "dnz_harvester/modifiers/abstract_modifier"
require "dnz_harvester/modifiers/find_replacer"
require "dnz_harvester/modifiers/range_selector"
require "dnz_harvester/modifiers/adder"
require "dnz_harvester/modifiers/finder_with"
require "dnz_harvester/modifiers/finder_without"

module DnzHarvester
  module Modifiers
    extend ::ActiveSupport::Concern
    
    def get(attribute_name)
      value = self.original_attributes[attribute_name]
      DnzHarvester::AttributeValue.new(value)
    end

    def fetch(options={})
      if options[:xpath]
        value = document ? document.xpath(options[:xpath]).text : nil
      elsif options[:path]
        value = document[options[:path]]
      end

      DnzHarvester::AttributeValue.new(value)
    end

    def compose(*args)
      options = args.extract_options!
      options[:separator] ||= ""

      values = []
      args.each do |v|
        if v.is_a?(DnzHarvester::AttributeValue) || v.is_a?(Array)
          values += v.to_a
        elsif v.is_a?(String)
          values << v
        end
      end

      DnzHarvester::AttributeValue.new(values.flatten.join(options[:separator]))
    end
  end
end