# The Supplejack Common code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack_core 

module ActiveModel
  # == Active Model Inclusion Validator
  module Validations
    class InclusionValidator < EachValidator

      def validate_each(record, attribute, value)
        exclusions = delimiter.respond_to?(:call) ? delimiter.call(record) : delimiter

        value = Array(value)
        matches = value.map {|v| exclusions.send(inclusion_method(exclusions), v) }
        
        if matches.include?(false)
          record.errors.add(attribute, :inclusion, options.except(:in, :within).merge!(:value => value))
        end
      end

    end
  end
end
