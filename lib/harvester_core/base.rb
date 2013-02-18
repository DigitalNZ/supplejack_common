module HarvesterCore
  class Base
    include HarvesterCore::Modifiers
    include HarvesterCore::OptionTransformers

    class_attribute :_base_urls
    class_attribute :_attribute_definitions
    class_attribute :_basic_auth
    class_attribute :_pagination_options
    class_attribute :_rejection_rules
    class_attribute :_throttle
    class_attribute :_environment

    self._base_urls = {}
    self._attribute_definitions = {}
    self._basic_auth = {}
    self._pagination_options = {}
    self._rejection_rules = {}
    self._environment = {}

    class << self
      def identifier
        @identifier ||= begin
          parent_adapter = self.ancestors[1].to_s.split("::")[1]
          "#{parent_adapter.underscore}_#{self.name.underscore}"
        end
      end

      def base_url(url)
        self._base_urls[self.identifier] ||= []
        self._base_urls[self.identifier] += [url]
      end

      def base_urls
        if self.basic_auth_credentials
          self._base_urls[self.identifier].map do |url|
            url = self.environment_url(url)
            url.gsub("http://", "http://#{self.basic_auth_credentials[:username]}:#{self.basic_auth_credentials[:password]}@") if url.present?
          end.compact
        else
          self._base_urls[self.identifier].map do |url|
            self.environment_url(url)
          end.compact
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

      def basic_auth(username, password)
        self._basic_auth[self.identifier] = {username: username, password: password}
      end

      def basic_auth_credentials
        self._basic_auth[self.identifier]
      end

      def paginate(options={})
        self._pagination_options[self.identifier] = options
      end

      def pagination_options
        self._pagination_options[self.identifier]
      end

      def attribute(name, options={}, &block)
        self._attribute_definitions[self.identifier] ||= {}
        self._attribute_definitions[self.identifier][name] = options || {}

        self._attribute_definitions[self.identifier][name][:block] = block if block_given?
      end

      def attributes(*args, &block)
        options = args.extract_options!

        args.each do |attribute|
          self.attribute(attribute, options, &block)
        end
      end

      def attribute_definitions
        self._attribute_definitions[self.identifier] ||= {}
        self._attribute_definitions[self.identifier]
      end

      def with_options(options={}, &block)
        yield(HarvesterCore::Scope.new(self, options))
      end

      def custom_instance_methods
        self.instance_methods(false)
      end

      def reject_if(&block)
        self._rejection_rules[self.identifier] = block
      end

      def rejection_rules
        self._rejection_rules[self.identifier]
      end

      def clear_definitions
        self._base_urls[self.identifier] = []
        self._attribute_definitions[self.identifier] = {}
        self._basic_auth[self.identifier] = nil
        self._pagination_options[self.identifier] = nil
        self._rejection_rules[self.identifier] = nil
      end

      def throttle(options={})
        self._throttle ||= []
        self._throttle << options
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

    attr_reader :original_attributes, :attributes, :field_errors

    def initialize(*args)
      @field_errors = {}
      @original_attributes = {}
    end

    def set_attribute_values
      self.class.attribute_definitions.each do |name, options|
        begin
          value = transformed_attribute_value(options, document)
          @original_attributes[name] ||= nil
          @original_attributes[name] = value if value.present?
        rescue StandardError => e
          @original_attributes[name] = nil
          self.field_errors[name] ||= []
          self.field_errors[name] << e.message
        end
      end
    end

    def transformed_attribute_value(options, document=nil)
      value = HarvesterCore::Utils.array(attribute_value(options, document))
      value = mapping_option(value, options[:mappings]) if options[:mappings]
      value = split_option(value, options[:separator]) if options[:separator]
      value = join_option(value, options[:join]) if options[:join]
      value = strip_html_option(value)
      value = strip_whitespace_option(value)
      value = truncate_option(value, options[:truncate]) if options[:truncate]
      value = parse_date_option(value, options[:date]) if options[:date]
      value.uniq
    end

    def attribute_value(options={}, document=nil)
      return options[:default] if options[:default]
      return HarvesterCore::ConditionalOption.new(document, options).value if options[:xpath] && options[:if]
      return HarvesterCore::XpathOption.new(document, options).value if options[:xpath]
      return strategy_value(options)
    end

    def strategy_value(name)
      raise NotImplementedError.new("All subclasses of HarvesterCore::Base must override #strategy_value.")
    end

    def document
      nil
    end

    def attributes
      return @attributes if @attributes
      @attributes = {}

      attribute_names.each do |name|
        @attributes[name] = self.final_attribute_value(name)
      end

      @attributes
    end

    def final_attribute_value(name)
      if block = self.class.attribute_definitions[name][:block] rescue nil
        begin
          evaluate_attribute_block(name, &block)
        rescue StandardError => e
          self.field_errors[name] ||= []
          self.field_errors[name] << "Error in the block: #{e.message}"
          return nil
        end
      elsif self.class.custom_instance_methods.include?(name)
        self.send(name)
      else
        original_attributes[name]
      end
    end

    def evaluate_attribute_block(name, &block)
      block_result = instance_eval(&block)
      return original_attributes[name] if block_result.nil?
      if block_result.is_a?(HarvesterCore::AttributeValue)
        block_result.to_a
      else
        block_result
      end
    end

    def attribute_names
      @attribute_names ||= self.class.attribute_definitions.keys + self.class.custom_instance_methods
    end

    def to_s
      "<#{self.class.to_s} @original_attributes=#{@original_attributes.inspect}>"
    end

    def method_missing(symbol, *args, &block)
      raise NoMethodError, "undefined method '#{symbol.to_s}' for #{self.class.to_s}" unless attribute_names.include?(symbol)
      final_attribute_value(symbol)
    end
  end
end