module DnzHarvester
  module Rss
    class Base < DnzHarvester::Base

      class_attribute :_default_elements
      self._default_elements = [:title, :url, :author, :content, :summary, :published, :updated, :categories, :entry_id]

      self._base_urls[self.identifier] = []
      self._attribute_definitions[self.identifier] = {}

      attr_reader :rss_entry

      class << self
        def attribute(name, options={})
          if !self._default_elements.include?(name) && options[:from] && options[:default].blank?
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

          records = entries.map {|entry| new(entry) }
          @records = records.map do |record|
            if rejection_rules
              record if !record.instance_eval(&rejection_rules)
            else
              record
            end
          end.compact
        end

        def feeds
          @feeds ||= Feedzirra::Feed.fetch_and_parse(self.base_urls)
        end
      end

      def initialize(rss_entry)
        @rss_entry = rss_entry
        super
      end

      def strategy_value(options={})
        options ||= {}
        return nil unless options[:from]
        rss_entry.send(options[:from])
      end

    end
  end
end