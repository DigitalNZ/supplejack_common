module Harvester
  module Oai
    class Base
      include Harvester::Base

      class_attribute :rejection_rules

      # attr_accessor :rejected

      def initialize(record)
        root = record.metadata.first

        @attributes ||= {}
        @attributes[:identifier] = record.header.identifier
        @attributes.merge!(self.class._default_values)

        root.each do |element|
          @attributes[element.name.to_sym] = element.texts
        end
      end

      # def self.reject(field, options={})
        
      # end

      def self.client
        @@client ||= OAI::Client.new(self._base_urls.first)
      end

      def self.records
        @@records ||= client.list_records.map do |record|
          self.new(record)
        end
      end
    end
  end
end