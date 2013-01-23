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

        def document
          @document ||= HarvesterCore::Utils.get(self.base_urls.first)
        end

        def records_json
          @records_json ||= JsonPath.on(document, self._record_selector).try(:first)
        end

        def records(options={})
          options = options.try(:symbolize_keys) || {}
          records = records_json.map {|attributes| self.new(attributes) }
          records = records[0..(options[:limit].to_i-1)] if options[:limit]
          records.map do |record|
            record.set_attribute_values
            if rejection_rules
              record if !record.instance_eval(&rejection_rules)
            else
              record
            end
          end.compact
        end

        def clear_definitions
          super
          self._record_selector = nil
        end

      end

      def initialize(*args)
        @json_attributes = args.first || {}
        super
      end

      def document
        @json_attributes
      end

      def raw_data
        document
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

    end
  end
end