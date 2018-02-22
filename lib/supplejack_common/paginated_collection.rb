module SupplejackCommon
  # Paginated Collection class
  class PaginatedCollection
    include Enumerable

    attr_reader :klass, :options

    attr_reader :page_parameter, :per_page_parameter, :per_page, :page, :counter

    def initialize(klass, pagination_options={}, options={})
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

      @options = options
      @counter = 0
    end

    def each(&block)
      klass.base_urls.each do |base_url|
        @records = klass.fetch_records(next_url(base_url))

        unless yield_from_records(&block)
          return nil
        end

        if paginated?
          while more_results? do
            @records.clear
            @records = klass.fetch_records(next_url(base_url))

            unless yield_from_records(&block)
              return nil
            end
          end
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
          joiner = url.match(/\?/) ? "&" : "?"
        if tokenised?
          @page = self.klass._document.present? ? self.klass.next_page_token(@next_page_token_location) : nil
          result = "#{url}#{joiner}#{url_options.to_query}"
          result = initial_url(url, joiner) if @initial_param.present?
          result
        else
          result = "#{url}#{joiner}#{url_options.to_query}"
          increment_page_counter!
          result
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
      @type == "page"
    end

    def current_page
      if page_pagination?
        @page
      else
        ((page - 1) / per_page) + 1
      end
    end

    def total_pages
      (self.klass.total_results(@total_selector) / per_page).ceil
    end

    def increment_page_counter!
      if page_pagination?
        @page += 1
      else
        @page += @per_page
      end
    end

    def more_results?
      if tokenised?
        return self.klass.next_page_token(@next_page_token_location).present?
      end
      current_page <= total_pages
    end

    def paginated?
      (page && per_page) || tokenised?
    end

    def tokenised?
      @type == 'token'
    end

    def yield_from_records(&block)
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

      return true
    end
  end
end
