module Harvester
  module Rss
    module Base
      extend ActiveSupport::Concern

      included do
        include Harvester::Base

        class_attribute :_attribute_definitions
        class_attribute :_default_elements

        self._attribute_definitions = {}
        self._default_elements = [:title, :url, :author, :content, :summary, :published, :updated, :categories, :entry_id]
      end

      module ClassMethods
        def attribute(name, options={})
          unless self._default_elements.include?(name)
            feedzirra_options = {}
            feedzirra_options[:value] = options[:value] if options[:value]
            feedzirra_options[:with] = options[:with] if options[:with]
            Feedzirra::Feed.add_common_feed_entry_element(options[:from], feedzirra_options)
          end

          self._attribute_definitions[name] = options || {}
        end

        def attributes(*args)
          options = args.pop if args.last.is_a?(Hash)

          args.each do |attribute|
            self._attribute_definitions[attribute] = options || {}
          end
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
        @attributes = {}
        @attributes.merge!(self.class._default_values)

        self.class._attribute_definitions.each do |name, options|
          from_method_name = options[:from] || name
          @attributes[name] = record.send(from_method_name)
        end
      end

    end
  end
end