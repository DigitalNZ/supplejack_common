# The Supplejack Common code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack 

module ActiveModel
  # == Active Model Length Validator
  module Validations
    class SizeValidator < LengthValidator

      def validate_each(record, attribute, value)
        value = Array(value)
        value_length = value.length

        CHECKS.each do |key, validity_check|
          next unless check_value = options[key]
          next if value_length.send(validity_check, check_value)

          errors_options = options.except(*RESERVED_OPTIONS)
          errors_options[:count] = check_value

          default_message = options[MESSAGES[key]]
          errors_options[:message] ||= default_message if default_message

          record.errors.add(attribute, MESSAGES[key], errors_options)
        end
      end

    end
  end
end
