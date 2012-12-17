module HarvesterCore
  module OptionTransformers
    class ParseDateOption
      Time.zone = "UTC"
      Chronic.time_class = Time.zone

      attr_reader :original_value, :format

      def initialize(original_value, format=nil)
        @original_value = Array(original_value)
        @format = format == true ? nil : format
      end

      def value
        original_value.map {|v| parse_date(v) }
      end

      def parse_date(v)
        if format
          DateTime.strptime(normalized(v), format).to_time
        else
          Chronic.parse(normalized(v), context: :past).try(:time)
        end
      end

      def normalized(date_string)
        date_string.gsub!(/circa.*(\d{4})/, '\1/1/1')
        date_string.gsub!(/^(\d{4})s?$/, '\1/1/1')
        date_string
      end

      # def time_array?(array)
      #   return false unless array.is_a?(Array)
      #   return false unless array.size == 10
      #   return false unless array.last == "UTC"
      #   return true
      # end
      
    end
  end
end