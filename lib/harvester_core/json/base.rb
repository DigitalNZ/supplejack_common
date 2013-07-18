module HarvesterCore
  module Json
    class Base < HarvesterCore::Base

      self.clear_definitions

      class_attribute :_record_selector

      attr_reader :json

      class << self

        def record_selector(path)
          self._record_selector = path
        end

        def document(url)
          if url.match(/^https?/)
            HarvesterCore::Request.get(url, self._throttle)
          elsif url.match(/^file/)
            File.read(url.gsub(/file:\/\//, ""))
          end
        end

        def records_json(url)
          JsonPath.on(document(url), self._record_selector).try(:first)
        end

        def fetch_records(url)
          records_json(url).map {|attributes| self.new(attributes) }
        end

        def records(options={})
          HarvesterCore::PaginatedCollection.new(self, {}, options)
        end

        def clear_definitions
          super
          self._record_selector = nil
        end

      end

      def initialize(json, from_raw=false)
        if json.is_a?(Hash)
          @json = json.to_json
        elsif json.is_a?(String)
          @json = json
        else
          @json = ""
        end
        super
      end

      def document
        @json
      end

      def raw_data
        document
      end

      def full_raw_data
        raw_data
      end

      def strategy_value(options={})
        options ||= {}
        path = options[:path]
        return nil unless path.present?

        Array(path).map do |p|
          JsonPath.on(document, p)
        end.flatten
      end

      def fetch(path)
        value = JsonPath.on(document, path)
        HarvesterCore::AttributeValue.new(value)
      end

    end
  end
end
