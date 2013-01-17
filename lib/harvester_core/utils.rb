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
      Rails.logger.info "GET: #{url}" if defined?(Rails)
      RestClient.get(url)
    end
  end
end