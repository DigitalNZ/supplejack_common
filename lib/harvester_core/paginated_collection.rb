module HarvesterCore
  class PaginatedCollection
    include Enumerable

    attr_reader :klass, :options

    attr_reader :page_parameter, :per_page_parameter, :per_page, :page, :counter
    attr_accessor :total
    
    def initialize(klass, pagination_options={}, options={})
      @klass = klass

      pagination_options ||= {}
      @page_parameter       = pagination_options[:page_parameter]
      @per_page_parameter   = pagination_options[:per_page_parameter]
      @per_page             = pagination_options[:per_page]
      @page                 = pagination_options[:page]
      @type                 = pagination_options[:type]

      @options = options
      @counter = 0
    end

    def each(&block)
      klass.base_urls.each do |base_url|
        @records = klass.fetch_records(next_url(base_url))
        self.total = klass._total_results if paginated?

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

    def next_url(url)
      if paginated?
        joiner = url.match(/\?/) ? "&" : "?"
        url = "#{url}#{joiner}#{url_options.to_query}"
        increment_page_counter!
        url
      else
        url
      end
    end

    def url_options
      {page_parameter => page, per_page_parameter => per_page}
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
      (total.to_f / per_page).ceil
    end

    def increment_page_counter!
      if page_pagination?
        @page += 1
      else
        @page += @per_page
      end
    end

    def more_results?
      current_page <= total_pages
    end

    def paginated?
      page && per_page
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