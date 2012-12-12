module DnzHarvester
  class DateParser
    Time.zone = "UTC"
    Chronic.time_class = Time.zone

    attr_reader :original_value, :format

    def initialize(original_value, format=nil)
      @original_value = original_value
      @format = format == true ? nil : format
    end

    def value
      if format
        DateTime.strptime(normalized, format).to_time
      else
        Chronic.parse(normalized, context: :past).try(:time)
      end
    end

    def normalized
      value = original_value.gsub(/circa.*(\d{4})/, '\1/1/1')
      value = value.gsub(/^(\d{4})s?$/, '\1/1/1')
      value
    end
    
  end
end