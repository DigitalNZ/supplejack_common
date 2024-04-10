# frozen_string_literal: true

module ActiveModel
  # == Active Model Inclusion Validator
  module Validations
    class InclusionValidator < EachValidator
      def validate_each(record, attribute, value)
        exclusions = delimiter.respond_to?(:call) ? delimiter.call(record) : delimiter

        value = Array(value)
        matches = value.map { |v| exclusions.send(inclusion_method(exclusions), v) }

        return unless matches.include?(false)

        record.errors.add(attribute, :inclusion, **options.except(:in, :within).merge!(value:))
      end
    end
  end
end
