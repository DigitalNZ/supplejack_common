# frozen_string_literal: true

module SupplejackCommon
  # Base class
  class Base
    include SupplejackCommon::Modifiers
    include ActiveModel::Validations
    include SupplejackCommon::DSL

    class << self
      def identifier
        @identifier ||= begin
          parent_adapter = ancestors[1].to_s.split('::')[1]
          "#{parent_adapter.underscore}_#{name.underscore}"
        end
      end

      def base_urls
        _base_urls[identifier].map do |url|
          basic_auth_url(environment_url(url))
        end.compact
      end

      def basic_auth_url(url)
        if basic_auth_credentials
          url.gsub('http://', "http://#{basic_auth_credentials[:username]}:#{basic_auth_credentials[:password]}@") if url.present?
        else
          url
        end
      end

      def environment_url(url)
        if url.is_a?(Hash)
          url[environment] if environment.present?
        else
          url
        end
      end

      def environment=(env)
        _environment[identifier] = env.to_s.to_sym
      end

      def environment
        _environment[identifier]
      end

      def basic_auth_credentials
        _basic_auth[identifier]
      end

      def pagination_options
        _pagination_options[identifier]
      end

      def attribute_definitions
        _attribute_definitions[identifier] ||= {}
        _attribute_definitions[identifier]
      end

      def enrichment_definitions
        _enrichment_definitions[identifier] ||= {}
        _enrichment_definitions[identifier]
      end

      def rejection_rules
        _rejection_rules[identifier]
      end

      def deletion_rules
        _deletion_rules[identifier]
      end

      def get_priority
        _priority[identifier] || 0
      end

      def match_concepts_rule
        _match_concepts[identifier]
      end

      def clear_definitions
        _base_urls[identifier] = []
        _attribute_definitions[identifier] = {}
        _enrichment_definitions[identifier] = {}
        _basic_auth[identifier] = nil
        _pagination_options[identifier] = nil
        _rejection_rules[identifier] = nil
        _deletion_rules[identifier] = nil
        _priority[identifier] = nil
        _match_concepts[identifier] = nil
      end

      def include_snippet(name)
        environment = module_parent.name.split('::').last.downcase.to_sym
        if snippet = Snippet.find_by_name(name, environment)
          class_eval <<-METHOD, __FILE__, __LINE__ + 1
            #{snippet.content}
          METHOD
        end
      end
    end

    attr_reader :attributes, :field_errors, :request_error

    def initialize(*_args)
      @field_errors = {}
      @attributes = {}
    end

    def set_attribute_values
      @attributes[:priority] = self.class.get_priority
      @attributes[:match_concepts] = self.class.match_concepts_rule

      begin
        self.class.attribute_definitions.each do |name, options|
          builder = AttributeBuilder.new(self, name, options)
          value = builder.value
          @attributes[name] ||= nil
          if builder.errors.any?
            field_errors[name] = builder.errors
          else
            @attributes[name] = AttributeValue.new(value).to_a unless value.nil? || (value == '')
          end
        end
      rescue StandardError => e
        @request_error = { exception_class: e.class.to_s, message: e.message, backtrace: e.backtrace[0..30] }
      end
    end

    def deletable?
      deletion_rules = self.class.deletion_rules
      return false if deletion_rules.nil?

      instance_eval(&deletion_rules)
    end

    def rejected?
      return false if self.class.rejection_rules.nil?
      self.class.rejection_rules.any? do |r|
        instance_eval(&r)
      end
    end

    def strategy_value(_options)
      raise NotImplementedError, 'All subclasses of SupplejackCommon::Base must override #strategy_value.'
    end

    def document
      nil
    end

    def attribute_names
      @attribute_names ||= self.class.attribute_definitions.keys
    end

    def to_s
      "<#{self.class} @attributes=#{@attributes.inspect}>"
    end

    def read_attribute_for_validation(attribute)
      attributes[attribute.to_sym]
    end

    def method_missing(symbol, *_args)
      raise NoMethodError, "undefined method '#{symbol}' for #{self.class}" unless attribute_names.include?(symbol)
      attributes[symbol]
    end
  end
end
