# frozen_string_literal: true

module ActiveModel
  # == Active Model Exclusion Validator
  module Validations
    class ExclusionValidator < EachValidator
      def validate_each(record, attribute, value)
        exclusions = delimiter.respond_to?(:call) ? delimiter.call(record) : delimiter

        value = Array(value)
        matches = value.map { |v| exclusions.send(inclusion_method(exclusions), v) }

        return unless matches.include?(true)

        record.errors.add(attribute, :exclusion, **options.except(:in, :within).merge!(value:))
      end
    end
  end
end
