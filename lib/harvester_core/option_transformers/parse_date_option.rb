module HarvesterCore
  module OptionTransformers
    class ParseDateOption
      Time.zone = "UTC"
      Chronic.time_class = Time.zone

      attr_reader :original_value, :format, :errors

      def initialize(original_value, format=nil)
        @original_value = Array(original_value)
        @format = format == true ? nil : format
        @errors = []
      end

      def value
        original_value.map {|v| parse_date(v) }
      end

      def parse_date(v)
        return v if [Date, DateTime, Time].include?(v.class)
        
        begin
          if format
            DateTime.strptime(normalized(v), format).to_time
          else
            Chronic.parse(normalized(v), context: :past).try(:time)
          end
        rescue StandardError => e
          @errors << "Cannot parse date: '#{normalized(v)}', #{e.message}"
        end
      end

      def normalized(date_string)
        date_string.gsub!(/circa.*(\d{4})/, '\1/1/1')
        date_string.gsub!(/^(\d{4})s?$/, '\1/1/1')
        date_string
      end
    end
  end
end