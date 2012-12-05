module DnzHarvester
  module Rss
    class Base < DnzHarvester::Base

      class_attribute :_default_elements
      self._default_elements = [:title, :url, :author, :content, :summary, :published, :updated, :categories, :entry_id]

      self._base_urls = []
      self._attribute_definitions = {}

      attr_reader :rss_entry

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

          @records = entries.map {|entry| new(entry) }
        end

        def feeds
          @feeds ||= Feedzirra::Feed.fetch_and_parse(self.base_urls)
        end
      end

      def initialize(rss_entry)
        @rss_entry = rss_entry
        super
      end

      def get_value_from(name)
        rss_entry.send(name)
      end

    end
  end
end