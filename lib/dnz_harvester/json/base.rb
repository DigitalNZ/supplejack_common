module DnzHarvester
  module Json
    class Base < DnzHarvester::Base

      self._base_urls[self.identifier] = []
      self._attribute_definitions[self.identifier] = {}

      class_attribute :_record_selector

      attr_reader :json_attributes

      class << self

        def record_selector(path)
          self._record_selector = path
        end

        def document
          @document ||= DnzHarvester::Utils.get(self.base_urls.first)
        end

        def records_json
          @records_json ||= JsonPath.on(document, self._record_selector).try(:first)
        end

        def records
          records = records_json.map {|attributes| self.new(attributes) }
          records.map do |record|
            if rejection_rules
              record if !record.instance_eval(&rejection_rules)
            else
              record
            end
          end.compact
        end

      end

      def initialize(*args)
        @json_attributes = args.first || {}
        super
      end

      def document
        @json_attributes
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
