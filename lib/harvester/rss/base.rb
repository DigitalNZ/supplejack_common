module Harvester
  module Rss
    class Base < Harvester::Base

      class_attribute :_default_elements
      self._default_elements = [:title, :url, :author, :content, :summary, :published, :updated, :categories, :entry_id]

      self._base_urls = []
      self._attribute_definitions = {}

      attr_reader :record

      class << self
        def attribute(name, options={})
          if !self._default_elements.include?(name) && options[:default].blank?
            feedzirra_options = {}
            feedzirra_options[:value] = options[:value] if options[:value]
            feedzirra_options[:with] = options[:with] if options[:with]
            Feedzirra::Feed.add_common_feed_entry_element(options[:from], feedzirra_options)
          end

          super(name, options)
        end

        def records
          entries ||= []
          feeds.each do |url, feed|
            entries += feed.entries
          end

          @@records = entries.map {|entry| new(entry) }
        end

        def feeds
          @@feeds ||= Feedzirra::Feed.fetch_and_parse(self._base_urls)
        end
      end

      def initialize(record)
        @record = record
        super
      end

      def set_attribute_values
        self.class._attribute_definitions.each do |name, options|
          value = nil
          value = options[:default] if options[:default].present?
          value = record.send(options[:from] || name) unless value
          @original_attributes[name] = value
        end
      end

    end
  end
end