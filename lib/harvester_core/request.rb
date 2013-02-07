require 'redis'

module HarvesterCore
  
  class Request

    class << self
      def get(url, options=[])
        self.new(url, options).get
      end
    end

    attr_accessor :url, :throttling_options

    def initialize(url, options=[])
      @url = url

      options ||= []
      @throttling_options = Hash[options.map {|option| [option[:host], option[:max_per_minute]] }]
    end

    def uri
      @uri ||= URI.parse(url)
    end

    def host
      uri.host
    end

    def get
      while limit_exceeded? do
        sleep 1
      end
      increment_count!
      request_resource
    end

    def current_count
      get_redis_values["count"]
    end

    def start_time
      Time.at(get_redis_values["time"]) if get_redis_values["time"]
    end

    def max_requests_per_minute
      throttling_options[self.host]
    end

    def limit_exceeded?
      return false if max_requests_per_minute.nil?
      return false unless start_time
      return false if Time.now > (start_time + 60.seconds)
      current_count >= max_requests_per_minute
    end

    def increment_count!
      if start_time.nil? 
        set_redis_values(Time.now, 1)
      elsif start_time < (Time.now - 1.minute)
        set_redis_values(Time.now, 1)
      else
        set_redis_values(start_time, current_count + 1)
      end
    end

    def set_redis_values(time, count)
      HarvesterCore.redis.set(host, {time: time.to_i, count: count}.to_json)
    end

    def get_redis_values
      @redis_values ||= begin
        values = HarvesterCore.redis.get(host)
        if values
          JSON.parse(values)
        else
          {}
        end
      end
    end

    def request_resource
      response = nil

      measure = Benchmark.measure do
        if defined?(Rails) && ::HarvesterCore.caching_enabled
          response = Rails.cache.fetch(url, :expires_in => 10.minutes) { RestClient.get(url) }
        else
          response = RestClient.get(url)
        end
      end

      if defined?(Rails)
        real_time = measure.real.round(4)
        Rails.logger.info "\nGET (#{real_time}): #{url}\n"
        puts "GET (#{real_time}): #{url}"
      end

      response
    end
  end
end