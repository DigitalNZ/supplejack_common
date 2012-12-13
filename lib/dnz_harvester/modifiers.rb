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
      
    end

    def compose(*args)
      
    end
  end
end