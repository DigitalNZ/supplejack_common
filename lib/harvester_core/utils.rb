require 'benchmark'

module HarvesterCore
  module Utils
    extend self

    #
    # Return a array no matter what.
    #
    def array(object)
      case object
      when Array
        object
      when String
        object.present? ? [object] : []
      when NilClass
        []
      else
        [object]
      end
    end

    def get(url)
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
        Rails.logger.info "GET (#{real_time}): #{url}"
        puts "GET (#{real_time}): #{url}"
      end

      response
    end

    def remove_default_namespace(xml)
      xml.gsub(/ xmlns='[A-Za-z0-9:\/\.\-]+'/, "")
    end
  end
end