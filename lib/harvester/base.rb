require 'active_support/core_ext/class/attribute'

module Harvester
  module Base
    extend ActiveSupport::Concern

    included do
      include Harvester::Filters::Finders
      include Harvester::Filters::Modifiers

      class_attribute :_base_urls
      class_attribute :_default_values

      self._base_urls = []
      self._default_values = {}

      attr_reader :attributes
    end

    module ClassMethods
      def base_url(url)
        self._base_urls << url
      end

      def default(field, value)
        self._default_values[field] = value
      end
    end

    def method_missing(symbol, *args, &block)
      raise NoMethodError, "undefined method '#{symbol.to_s}' for #{self.class.to_s}" unless @attributes.has_key?(symbol)
      @attributes[symbol]
    end
  end
end