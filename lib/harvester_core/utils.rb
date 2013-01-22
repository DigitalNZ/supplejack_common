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
        response = RestClient.get(url)
      end

      if defined?(Rails)
        real_time = measure.real.round(4)
        Rails.logger.info "GET (#{real_time}): #{url}"
        puts "GET (#{real_time}): #{url}"
      end

      response
    end
  end
end