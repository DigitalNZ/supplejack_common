# The Supplejack code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack_core 

module HarvesterCore
  module Modifiers
    class DateParser < AbstractModifier
      Time.zone = "UTC"
      Chronic.time_class = Time.zone

      attr_reader :original_value, :format, :errors

      def initialize(original_value, format=nil)
        @original_value = Array(original_value)
        @format = format == true ? nil : format
        @errors = []
      end

      def modify
        original_value.map {|v| parse_date(v) }
      end

      def parse_date(v)
        return v if [Date, DateTime, Time].include?(v.class)
        
        begin
          normalized_time = normalized(v)

          if format
            DateTime.strptime(normalized_time, format).to_time
          else
            time = Chronic.parse(normalized_time, context: :past).try(:time)

            if time
              return time
            else
              begin
                Time.parse(normalized_time)
              rescue ArgumentError => e
                nil
              end
            end
          end
        rescue StandardError => e
          @errors << "Cannot parse date: '#{normalized_time}', #{e.message}"
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