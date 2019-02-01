# frozen_string_literal: true

# This is overriding the existing initialize method within the OAI gem.
# The reason for this is so that we can specify retries in Faraday

module OAI
  # lib/supplejack_common/client.rb
  class Client
    attr_reader :channel_options

    def initialize(base_url, options = {}, proxy = nil, channel_options)
      @base = URI.parse base_url
      @debug = options.fetch(:debug, false)
      @parser = options.fetch(:parser, 'rexml')
      @channel_options = channel_options

      @http_client = options.fetch(:http) do
        Faraday.new(url: @base.clone, proxy: proxy) do |builder|
          follow_redirects = options.fetch(:redirects, true)
          if follow_redirects
            count = follow_redirects.is_a?(Integer) ? follow_redirects : 5

            require 'faraday_middleware'
            builder.response :follow_redirects, limit: count
          end
          builder.adapter :net_http
          builder.request :retry, max: 5,
                                  interval: 1,
                                  interval_randomness: 0.5,
                                  backoff_factor: 2
        end
      end

      # load appropriate parser
      case @parser
      when 'libxml'
        begin
          require 'rubygems'
          require 'xml/libxml'
        rescue StandardError
          raise OAI::Exception, 'xml/libxml not available'
        end
      when 'rexml'
        require 'rexml/document'
        require 'rexml/xpath'
      else
        raise OAI::Exception, "unknown parser: #{@parser}"
      end
    end

    def get(uri)
      if defined?(ActionCable)
        ActionCable.server.broadcast(
          "#{channel_options[:environment]}_channel_#{channel_options[:parser_id]}_#{channel_options[:user_id]}",
          status_log: "Requesting URL: #{uri}"
        )
      end

      response = @http_client.get("?#{uri.query}")

      if defined?(ActionCable)
        ActionCable.server.broadcast(
          "#{channel_options[:environment]}_channel_#{channel_options[:parser_id]}_#{channel_options[:user_id]}",
          status_log: ::CodeRay.scan(response.body, :xml).html(line_numbers: :table).html_safe
        )
      end

      response.body
    end
  end
end
