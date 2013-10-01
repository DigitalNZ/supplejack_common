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

      def deletion_rules
        self._deletion_rules[self.identifier]
      end

      def get_priority
        self._priority[self.identifier] || 0
      end

      def clear_definitions
        self._base_urls[self.identifier] = []
        self._attribute_definitions[self.identifier] = {}
        self._enrichment_definitions[self.identifier] = {}
        self._basic_auth[self.identifier] = nil
        self._pagination_options[self.identifier] = nil
        self._rejection_rules[self.identifier] = nil
        self._deletion_rules[self.identifier] = nil
        self._priority[self.identifier] = nil
      end

      def include_snippet(name)
        if defined?(Snippet)
          environment = self.parent.name.split('::').last.downcase.to_sym
          if snippet = Snippet.find_by_name(name, environment)
            self.class_eval <<-METHOD, __FILE__, __LINE__ + 1
              #{snippet.content}
            METHOD
          end
        end
      end
    end

    attr_reader :attributes, :field_errors, :request_error

    def initialize(*args)
      @field_errors = {}
      @attributes = {}
    end

    def set_attribute_values
      @attributes[:priority] = self.class.get_priority

      begin
        self.class.attribute_definitions.each do |name, options|
          builder = AttributeBuilder.new(self, name, options)
          value = builder.value
          @attributes[name] ||= nil
          if builder.errors.any?
            self.field_errors[name] = builder.errors
          else
            @attributes[name] = AttributeValue.new(value).to_a unless value.nil? or value == ""
          end
        end
      rescue StandardError => e
        @request_error = {exception_class: e.class.to_s, message: e.message, backtrace: e.backtrace[0..30]}
      end
    end

    def deletable?
      deletion_rules = self.class.deletion_rules
      return false if deletion_rules.nil?
      return self.instance_eval(&deletion_rules)
    end

    def rejected?
      return false if self.class.rejection_rules.nil?
      self.class.rejection_rules.any? do |r|
        self.instance_eval(&r)
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
