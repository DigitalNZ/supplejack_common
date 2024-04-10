# frozen_string_literal: true

require 'redis'
require 'retriable'

module SupplejackCommon
  # SJ Request class
  class Request
    class << self
      def get(url, request_timeout, options = [], headers = {}, proxy = nil)
        new(url, request_timeout, options, headers, proxy).get
      end

      def scroll(url, request_timeout, options = [], headers = {})
        new(url, request_timeout, options, headers).scroll
      end
    end

    attr_accessor :url, :throttling_options, :request_timeout, :headers, :proxy

    def initialize(url, request_timeout, options = [], headers = {}, proxy = nil)
      @url = url

      options ||= []
      @throttling_options = options.to_h do |option|
        [option[:host], option[:delay]]
      end
      @request_timeout = request_timeout || 60_000
      @headers = headers
      @proxy = proxy
    end

    def uri
      @uri ||= URI.parse(url)
    end

    def host
      @host ||= uri.host
    end

    def redis_lock_key
      "harvester.throttle.#{host}"
    end

    def get
      acquire_lock do
        request_resource
      rescue RestClient::NotFound
        Sidekiq.logger.info 'Record not found, moving on..'
        next
      end
    end

    def scroll
      acquire_lock do
        http_verb = if url.include? '_scroll'
                      :post
                    else
                      :get
                    end

        RestClient::Request.execute(method: http_verb, url:, timeout: request_timeout, headers:,
                                    max_redirects: 0) do |response, _request, _result|
          response
        end
      end
    end

    def acquire_lock
      loop do
        if SupplejackCommon.redis.setnx(redis_lock_key, 0)
          SupplejackCommon.redis.pexpire(redis_lock_key, delay)

          Sidekiq.logger.info "Acquired lock for #{host}, requesting URL" if defined?(Sidekiq)
          return yield
        else
          pttl = SupplejackCommon.redis.pttl(redis_lock_key)
          SupplejackCommon.redis.pexpire(redis_lock_key, delay) if pttl == -1
          sleep_time = (pttl + 10) / 1000.0

          Sidekiq.logger.info "Did not acquire lock for #{host}, sleeping for #{sleep_time}s" if defined?(Sidekiq)
          sleep(sleep_time) if sleep_time.positive?
        end
      end
    end

    def delay
      (throttling_options[host].to_f * 1000).to_i
    end

    def request_url
      ::Retriable.retriable(tries: 5, base_interval: 1, multiplier: 2) do
        ::Sidekiq.logger.info "Retrying RestClient request #{url}" if defined?(Sidekiq)
        RestClient::Request.execute(
          method: :get,
          url:,
          timeout: request_timeout,
          headers:,
          proxy:
        )
      end
    end

    def request_resource
      start_time = Time.now
      response = nil

      measure = Benchmark.measure do
        response = if defined?(Rails) && ::SupplejackCommon.caching_enabled
                     Rails.cache.fetch(url, expires_in: 10.minutes) { request_url }
                   else
                     request_url
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
