module HarvesterCore
  module OptionTransformers
    class JoinOption
        
      attr_reader :original_value, :joiner

      def initialize(original_value, joiner)
        @original_value = Array(original_value)
        @joiner = joiner.to_s
      end

      def value
        [original_value.join(joiner)]
      end
      
    end
  end
end