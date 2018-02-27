# frozen_string_literal: true

module SupplejackCommon
  # SJ Json Class
  module Json
    class Base < SupplejackCommon::Base
      clear_definitions

      class_attribute :_record_selector
      class_attribute :_document

      attr_reader :json

      class << self
        def record_selector(path)
          self._record_selector = path
        end

        def document(url)
          if url =~ /^https?/
            self._document = SupplejackCommon::Request.get(url, _request_timeout, _throttle, _http_headers)
            _document
          elsif url =~ /^file/
            File.read(url.gsub(/file:\/\//, ''))
          end
        end

        def next_page_token(next_page_token_location)
          JsonPath.on(_document, next_page_token_location).try(:first)
        end

        def total_results(total_selector)
          JsonPath.on(_document, total_selector).try(:first).to_f
        end

        def records_json(url)
          records = JsonPath.on(document(url), _record_selector).try(:first)
          records = [records] if records.is_a? Hash
          records
        end

        def fetch_records(url)
          records_json(url).map { |attributes| new(attributes) }
        end

        def records(options = {})
          SupplejackCommon::PaginatedCollection.new(self, pagination_options || {}, options)
        end

        def clear_definitions
          super
          self._record_selector = nil
          self._document = nil
        end
      end

      def initialize(json, from_raw = false)
        @json = if json.is_a?(Hash)
                  json.to_json
                elsif json.is_a?(String)
                  json
                else
                  ''
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

      def strategy_value(options = {})
        options ||= {}
        path = options[:path]
        return nil unless path.present?

        Array(path).map do |p|
          JsonPath.on(document, p)
        end.flatten
      end

      def fetch(path)
        value = JsonPath.on(document, path)
        SupplejackCommon::AttributeValue.new(value)
      end
    end
  end
end
