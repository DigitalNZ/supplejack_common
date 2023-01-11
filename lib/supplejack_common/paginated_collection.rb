# frozen_string_literal: true

module SupplejackCommon
  # Paginated Collection class
  # rubocop:disable Metrics/ClassLength
  class PaginatedCollection
    include Enumerable

    attr_reader :klass, :options

    attr_reader :page_parameter,
                :per_page_parameter,
                :per_page,
                :page,
                :counter,
                :type,
                :next_page_token_location,
                :total_selector,
                :duration_parameter,
                :duration_value,
                :initial_param

    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/PerceivedComplexity
    def initialize(klass, pagination_options = {}, options = {})
      @klass = klass

      pagination_options ||= {}
      @page_parameter             = pagination_options[:page_parameter]
      @per_page_parameter         = pagination_options[:per_page_parameter]
      @per_page                   = pagination_options[:per_page]
      @page                       = pagination_options[:page]
      @type                       = pagination_options[:type]
      @next_page_token_location   = pagination_options[:next_page_token_location]
      @total_selector             = pagination_options[:total_selector]
      @initial_param              = pagination_options[:initial_param]
      @counter                    = pagination_options[:counter] || 0
      @job                        = pagination_options[:job]
      @base_urls                  = pagination_options[:base_urls] || []
      @block                      = pagination_options[:block]
      @duration_parameter         = pagination_options[:duration_parameter]
      @duration_value             = pagination_options[:duration_value]
      @scroll_type                = pagination_options[:scroll_type] || 'elasticsearch'

      puts "Starting from #{@base_urls[0]}"

      @options = options

      if paginated?
        @job&.states&.create!(page: @page, per_page: @per_page, limit: options[:limit], counter: @counter)
      else
        @job&.states&.create!(base_urls: @base_urls, limit: options[:limit], counter: @counter)
      end
    end
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/PerceivedComplexity

    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/PerceivedComplexity
    # rubocop:disable Metrics/AbcSize
    def each(&block)
      completed_base_urls = @job&.states&.last&.base_urls || []
      (klass.base_urls - completed_base_urls).each do |base_url|
        @records = klass.fetch_records(next_url(base_url))

        return nil unless yield_from_records(&block)
        unless paginated? || scroll?
          completed_base_urls = @job&.states&.last&.base_urls
          @job&.states&.create!(base_urls: completed_base_urls.push(base_url), limit: options[:limit], counter: @counter)
          next
        end

        while more_results?
          @job&.states&.create!(page: @page, per_page: @per_page, limit: options[:limit], counter: @counter)

          @records.clear
          @records = klass.fetch_records(next_url(base_url))

          return nil unless yield_from_records(&block)
        end
      end
    end
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/PerceivedComplexity
    # rubocop:enable Metrics/AbcSize

    private

    def initial_url(url)
      url = "#{url}#{joiner(url)}#{@initial_param}"
      @initial_param = nil
      url
    end

    def next_url(url)
      return next_tokenised_url(url) if tokenised?
      return next_paginated_url(url) if paginated?
      return next_scroll_url(url) if scroll?
      return @block.call(self, url) if @block

      url
    end

    def next_tokenised_url(url)
      @page = klass._document.present? ? klass.next_page_token(@next_page_token_location) : nil
      result = "#{url}#{joiner(url)}#{url_options.to_query}"

      if @block
        init_param = @initial_param ? [@initial_param.split('=')].to_h : {}
        @initial_param = nil
        return @block.call(url, joiner(url), url_options.merge(init_param))
      end

      result = initial_url(url) if @initial_param.present?
      result
    end

    def next_paginated_url(url)
      result = if @block
                 @block.call(url, joiner(url), url_options)
               else
                 "#{url}#{joiner(url)}#{url_options.to_query}"
               end
      increment_page_counter!
      result
    end

    def next_scroll_url(url)
      return url + joiner(url) + scroll_url_query_params unless klass._document.present?

      case @scroll_type
      when 'elasticsearch'
        scroll_id = JSON.parse(klass._document.body)['_scroll_id']
        base_url = url.match('(?<base_url>.+\/search)')[:base_url]
        next_scroll_url = base_url + "/_search/scroll/#{scroll_id}?" + scroll_url_query_params
      when 'tepapa'
        base_url = url.match('(?<base_url>.+\/collection)')[:base_url]
        next_scroll_url = base_url + klass._document.headers[:location] + joiner(url) + scroll_url_query_params
      else
        raise StandardError, 'You have requested a scroll type that the worker does not understand'
      end

      puts "The next scroll URL is #{next_scroll_url}"
      next_scroll_url
    end

    def scroll_url_query_params
      return '' unless duration_parameter.present? && duration_value.present?
      { duration_parameter => duration_value }.to_query
    end

    def url_options
      options = {}
      options[page_parameter] = page if page_parameter.present?
      options[per_page_parameter] = per_page if per_page_parameter.present?
      options
    end

    def page_pagination?
      @type == 'page'
    end

    def current_page
      if page_pagination?
        @page
      else
        ((page - 1) / per_page) + 1
      end
    end

    def total_pages
      (klass.total_results(@total_selector).to_f / per_page.to_f).ceil
    end

    def increment_page_counter!
      @page += if page_pagination?
                 1
               else
                 @per_page
               end
    end

    def more_results?
      if scroll?
        if @scroll_type == 'elasticsearch'
          return JSON.parse(klass._document.body)['hits']['hits'].present?
        else
          # Te Papa returns a 303 when there are more scroll results in their end point
          return klass._document.code == 303
        end
      end

      if tokenised?
        return klass.next_page_token(@next_page_token_location).present?
      end
      current_page <= total_pages
    end

    def paginated?
      (page && per_page) || tokenised?
    end

    def tokenised?
      @type == 'token'
    end

    def scroll?
      @type == 'scroll'
    end

    def joiner(url)
      url =~ /\?/ ? '&' : '?'
    end

    def yield_from_records
      while record = @records.shift
        record.set_attribute_values

        if record.rejected?
          next
        else
          @counter += 1
          yield(record)
        end

        return nil if options[:limit] && @counter >= options[:limit]
      end

      true
    end
  end
  # rubocop:enable Metrics/ClassLength
end
