# frozen_string_literal: true

module ActiveModel
  module Validations
    class FormatValidator < EachValidator
      def validate_each(record, attribute, value)
        value = Array(value)

        if (regexp = options[:with])
          matches = value.map { |v| v !~ regexp }
          record_error(record, attribute, :with, value) if matches.include?(true)
        elsif (regexp = options[:without])
          record_error(record, attribute, :without, value) if value.to_s =~ regexp
        end
      end
    end
  end
end
