module Harvester
  module Xml
    module Base
      extend ActiveSupport::Concern

      included do
        include Harvester::Base

        class_attribute :_attribute_definitions

        self._attribute_definitions = {}
      end

      module ClassMethods
        def attribute(name, options={})
          self._attribute_definitions[name] = options || {}
        end

        def records
          records = Hash.from_xml RestClient.get(self._base_urls.first)
          records = records["titles"]

          @@records = records.map {|hash| new(hash["slug"]) }
        end
      end

      def initialize(slug)
        @slug = slug
        @attributes = {}
      end

      def fetch_record_xml
        @record_xml ||= RestClient.get("#{self.class._base_urls.first}#{@slug}")
      end

      def document
        @document ||= Nokogiri.parse(fetch_record_xml)
      end

      def set_attribute_values
        self.class._attribute_definitions.each do |attribute_name, options|
          options ||= {}
          value = nil

          if options[:default]
            value = options[:default]
          elsif options[:xpath] && options[:object]
            value = document.xpath("//#{options[:xpath]}")
          elsif options[:xpath]
            value = document.xpath("//#{options[:xpath]}").text
          elsif options.empty?
            value = document.xpath("//#{attribute_name}").text
          end

          if options[:separator]
            value = value.split(options[:separator])
          end

          @attributes[attribute_name] = value
        end

        @attributes
      end
    end
  end
end