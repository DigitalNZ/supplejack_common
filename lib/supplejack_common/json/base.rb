# The Supplejack Common code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack 

module SupplejackCommon
  module Json
    class Base < SupplejackCommon::Base

      self.clear_definitions

      class_attribute :_record_selector
      class_attribute :_total_results

      attr_reader :json

      class << self

        def record_selector(path)
          self._record_selector = path
        end

        def document(url)
          if url.match(/^https?/)
            SupplejackCommon::Request.get(url, self._request_timeout, self._throttle)
          elsif url.match(/^file/)
            File.read(url.gsub(/file:\/\//, ""))
          end
        end

        def records_json(url)
          JsonPath.on(document(url), self._record_selector).try(:first)
        end

        def fetch_records(url)
          self._total_results ||= JsonPath.on(document(url), self.pagination_options[:total_selector]).first if pagination_options
          records_json(url).map {|attributes| self.new(attributes) }
        end

        def records(options={})
          SupplejackCommon::PaginatedCollection.new(self, self.pagination_options || {}, options)
        end

        def clear_definitions
          super
          self._record_selector = nil
          self._total_results = nil
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
        SupplejackCommon::AttributeValue.new(value)
      end

    end
  end
end
