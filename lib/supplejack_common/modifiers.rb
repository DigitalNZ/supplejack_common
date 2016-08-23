# The Supplejack Common code is
# Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# See https://github.com/DigitalNZ/supplejack for details.
#
# Supplejack was created by DigitalNZ at the
# National Library of NZ and the Department of Internal Affairs.
# http://digitalnz.org/supplejack

require 'supplejack_common/modifiers/abstract_modifier'
require 'supplejack_common/modifiers/mapper'
require 'supplejack_common/modifiers/range_selector'
require 'supplejack_common/modifiers/adder'
require 'supplejack_common/modifiers/finder_with'
require 'supplejack_common/modifiers/finder_without'
require 'supplejack_common/modifiers/splitter'
require 'supplejack_common/modifiers/truncator'
require 'supplejack_common/modifiers/date_parser'
require 'supplejack_common/modifiers/whitespace_stripper'
require 'supplejack_common/modifiers/whitespace_compactor'
require 'supplejack_common/modifiers/html_stripper'
require 'supplejack_common/modifiers/joiner'


module SupplejackCommon
  module Modifiers
    extend ::ActiveSupport::Concern
    
    def get(attribute_name)
      value = self.attributes[attribute_name]
      SupplejackCommon::AttributeValue.new(value)
    end

    def compose(*args)
      options = args.extract_options!
      options[:separator] ||= ''

      values = []
      args.each do |v|
        if v.is_a?(SupplejackCommon::AttributeValue) || v.is_a?(Array)
          values += v.to_a
        elsif v.is_a?(String)
          values << v
        end
      end

      SupplejackCommon::AttributeValue.new(values.flatten.join(options[:separator]))
    end

    def concept_lookup(url)
      values = SupplejackApi::Concept.where('fragments.sameAs' => url).map(&:concept_id)
      SupplejackCommon::AttributeValue.new(values)
    end
  end
end
