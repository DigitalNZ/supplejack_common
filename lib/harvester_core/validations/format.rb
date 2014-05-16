# The Supplejack code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack_core 

module ActiveModel
  module Validations
    class FormatValidator < EachValidator
      def validate_each(record, attribute, value)
        value = Array(value)

        if options[:with]
          regexp = option_call(record, :with)
          matches = value.map {|v| v !~ regexp }
          record_error(record, attribute, :with, value) if matches.include?(true)
        elsif options[:without]
          regexp = option_call(record, :without)
          record_error(record, attribute, :without, value) if value.to_s =~ regexp
        end
      end

    end
  end
end
