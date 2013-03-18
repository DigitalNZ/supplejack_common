module HarvesterCore
  module Json
    class Base < HarvesterCore::Base

      self.clear_definitions

      class_attribute :_record_selector

      attr_reader :json_attributes

      class << self

        def record_selector(path)
          self._record_selector = path
        end

        def document(url)
          HarvesterCore::Request.get(url, self._throttle)
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

      def initialize(attributes, from_raw=false)
        if attributes.is_a?(Hash)
          @json_attributes = attributes || {}
        elsif attributes.is_a?(String)
          @json_attributes = JSON.parse(attributes)
        else
          @json_attributes = {}
        end
        super
      end

      def document
        @json_attributes
      end

      def raw_data
        document
      end

      def full_raw_data
        raw_data.to_json
      end

      def strategy_value(options={})
        options ||= {}
        path = options[:path]
        return nil unless path.present?

        if path.is_a?(Array)
          path.map {|p| json_attributes[p] }
        else
          json_attributes[path]
        end
      end

      def fetch(path)
        value = document[path.to_s]
        HarvesterCore::AttributeValue.new(value)
      end

    end
  end
end
