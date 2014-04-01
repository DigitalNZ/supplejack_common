require 'redis'

module HarvesterCore
  
  class Request

    class << self
      def get(url, request_timeout, options=[])
        self.new(url,request_timeout, options).get
      end
    end

    attr_accessor :url, :throttling_options, :request_timeout

    def initialize(url, request_timeout, options=[])
      # Prevents from escaping escaped URL
      # Sifter #6439
      @url = URI.escape(URI.unescape(url))
      
      options ||= []
      @throttling_options = Hash[options.map {|option| [option[:host], option[:delay]] }]
      @request_timeout = request_timeout || 60000
    end

    def uri
      @uri ||= URI.parse(url)
    end

    def host
      @host ||= uri.host
    end

    def redis_lock_key
      "harvester.throttle.#{self.host}"
    end
 
    def get
      acquire_lock do
        self.request_resource
      end
    end

    def acquire_lock(&block)
      while(true)
        if HarvesterCore.redis.setnx(redis_lock_key, 0)
          HarvesterCore.redis.pexpire(redis_lock_key, delay)
           
          Sidekiq.logger.info "Acquired lock for #{host}, requesting URL" if defined?(Sidekiq)
          return yield
        else
          pttl = HarvesterCore.redis.pttl(redis_lock_key)
          HarvesterCore.redis.pexpire(redis_lock_key, delay) if pttl == -1
          sleep_time = (pttl + 10) / 1000.0
 
          Sidekiq.logger.info "Did not acquire lock for #{host}, sleeping for #{sleep_time}s" if defined?(Sidekiq)
          sleep(sleep_time) if sleep_time > 0
        end
      end
    end

    def delay
      (throttling_options[self.host].to_f * 1000).to_i
    end

    def request_url
      RestClient::Request.execute(method: :get, url: self.url, timeout: self.request_timeout)
    end

    def request_resource
      start_time = Time.now
      response = nil

      measure = Benchmark.measure do
        if defined?(Rails) && ::HarvesterCore.caching_enabled
          response = Rails.cache.fetch(url, :expires_in => 10.minutes) { request_url }
        else
          response = request_url
        end
      end

      if defined?(Sidekiq)
        real_time = measure.real.round(4)
        Sidekiq.logger.info "GET (#{real_time}): #{url}, started #{start_time.utc.iso8601}"
      end

      response
    end
  end
end