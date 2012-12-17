module HarvesterCore
  module OptionTransformers
    class MappingOption

      attr_reader :original_value, :mappings
      
      def initialize(original_value, mappings)
        @original_value = Array(original_value)
        @mappings = mappings
      end

      def value
        original_value.map {|v| mapped_value(v) }
      end

      def mapped_value(v)
        mappings.each do |regexp, substitution|
          new_value = v.gsub!(regexp, substitution)
          return new_value if new_value
        end

        return v
      end
    end
  end
end