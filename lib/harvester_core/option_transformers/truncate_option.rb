module HarvesterCore
  module OptionTransformers
    class TruncateOption
      
      attr_reader :original_value, :length, :omission

      def initialize(original_value, length, omission="")
        @original_value = Array(original_value)
        @length = length.to_i
        @omission = omission.to_s
      end

      def value
        original_value.map do |v|
          v.is_a?(String) ? v.truncate(length, omission: omission) : v
        end
      end
    end
  end
end