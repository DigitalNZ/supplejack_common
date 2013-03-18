module HarvesterCore
  class Base
    include HarvesterCore::Modifiers
    include ActiveModel::Validations
    include HarvesterCore::DSL

    class << self
      def identifier
        @identifier ||= begin
          parent_adapter = self.ancestors[1].to_s.split("::")[1]
          "#{parent_adapter.underscore}_#{self.name.underscore}"
        end
      end

      def base_urls
        self._base_urls[self.identifier].map do |url|
          self.basic_auth_url(environment_url(url))
        end.compact
      end

      def basic_auth_url(url)
        if self.basic_auth_credentials
          url.gsub("http://", "http://#{self.basic_auth_credentials[:username]}:#{self.basic_auth_credentials[:password]}@") if url.present?
        else
          url
        end
      end

      def environment_url(url)
        if url.is_a?(Hash)
          return url[self.environment] if self.environment.present?
        else
          url
        end
      end

      def environment=(env)
        self._environment[self.identifier] = env.to_s.to_sym
      end

      def environment
        self._environment[self.identifier]
      end

      def basic_auth_credentials
        self._basic_auth[self.identifier]
      end

      def pagination_options
        self._pagination_options[self.identifier]
      end

      def attribute_definitions
        self._attribute_definitions[self.identifier] ||= {}
        self._attribute_definitions[self.identifier]
      end

      def enrichment_definitions
        self._enrichment_definitions[self.identifier] ||= {}
        self._enrichment_definitions[self.identifier]
      end

      def rejection_rules
        self._rejection_rules[self.identifier]
      end

      def clear_definitions
        self._base_urls[self.identifier] = []
        self._attribute_definitions[self.identifier] = {}
        self._enrichment_definitions[self.identifier] = {}
        self._basic_auth[self.identifier] = nil
        self._pagination_options[self.identifier] = nil
        self._rejection_rules[self.identifier] = nil
      end

      def include_snippet(name)
        if defined?(Snippet)
          if snippet = Snippet.find_by_name(name)
            self.class_eval <<-METHOD, __FILE__, __LINE__ + 1
              #{snippet.content}
            METHOD
          end
        end
      end
    end

    attr_reader :attributes, :field_errors

    def initialize(*args)
      @field_errors = {}
      @attributes = {}
    end

    def set_attribute_values
      self.class.attribute_definitions.each do |name, options|
        builder = AttributeBuilder.new(self, name, options)
        value = builder.value
        @attributes[name] ||= nil
        if builder.errors.any?
          self.field_errors[name] = builder.errors
        else
          @attributes[name] = value if value.present?
        end
      end

      self.class.enrichment_definitions.each do |name, block|
        enrichment = Enrichment.new(name, block, self)

        if enrichment.enrichable?
          enrichment.set_attribute_values
          @attributes.merge!(enrichment.attributes)
        end
      end
    end

    def strategy_value(options)
      raise NotImplementedError.new("All subclasses of HarvesterCore::Base must override #strategy_value.")
    end

    def document
      nil
    end

    def attribute_names
      @attribute_names ||= self.class.attribute_definitions.keys
    end

    def to_s
      "<#{self.class.to_s} @attributes=#{@attributes.inspect}>"
    end

    def read_attribute_for_validation(attribute)
      attributes[attribute.to_sym]
    end

    def method_missing(symbol, *args, &block)
      raise NoMethodError, "undefined method '#{symbol.to_s}' for #{self.class.to_s}" unless attribute_names.include?(symbol)
      attributes[symbol]
    end
  end
end