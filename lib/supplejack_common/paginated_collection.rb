# frozen_string_literal: true

module SupplejackCommon
  # Paginated Collection class
  class PaginatedCollection
    include Enumerable

    attr_reader :klass, :options

    attr_reader :page_parameter, :per_page_parameter, :per_page, :page, :counter

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
      puts "Starting from #{@base_urls[0]}"

      @options = options

      if paginated?
        @job&.states&.create!(page: @page, per_page: @per_page, limit: options[:limit], counter: @counter, total_selector: @total_selector)
      else
        @job&.states&.create!(base_urls: @base_urls, limit: options[:limit], counter: @counter)
      end
    end

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
          @records.clear
          @records = klass.fetch_records(next_url(base_url))

          @job&.states&.create!(page: @page, per_page: @per_page, limit: options[:limit], counter: @counter, total_selector: @total_selector)

          return nil unless yield_from_records(&block)
        end
      end
    end

    private

    def initial_url(url, joiner)
      url = "#{url}#{joiner}#{@initial_param}"
      @initial_param = nil
      url
    end

    def next_url(url)
      if paginated?
        joiner = url =~ /\?/ ? '&' : '?'
        if tokenised?
          @page = klass._document.present? ? klass.next_page_token(@next_page_token_location) : nil
          result = "#{url}#{joiner}#{url_options.to_query}"
          result = initial_url(url, joiner) if @initial_param.present?
          result
        else
          result = "#{url}#{joiner}#{url_options.to_query}"
          increment_page_counter!
          result
        end
      elsif scroll?
        if klass._document.present?
          base_url = url.match('(?<base_url>.+\/collection)')[:base_url]
          base_url + klass._document.headers[:location]
        else
          url
        end
      else
        url
      end
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
      return klass._document.code == 303 if scroll?

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
end
