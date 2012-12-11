module DnzHarvester
  class Base
    include DnzHarvester::Filters::Finders
    include DnzHarvester::Filters::Modifiers
    include DnzHarvester::ValueSeparatorHelper

    class_attribute :_base_urls
    class_attribute :_attribute_definitions
    class_attribute :_basic_auth

    self._base_urls = {}
    self._attribute_definitions = {}
    self._basic_auth = {}

    attr_reader :original_attributes, :attributes

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
            url.gsub("http://", "http://#{self.basic_auth_credentials[:username]}:#{self.basic_auth_credentials[:password]}@")
          end
        else
          self._base_urls[self.identifier]
        end
      end

      def basic_auth(username, password)
        self._basic_auth[self.identifier] = {username: username, password: password}
      end

      def basic_auth_credentials
        self._basic_auth[self.identifier]
      end

      def attribute(name, options={}, &block)
        self._attribute_definitions[self.identifier] ||= {}
        self._attribute_definitions[self.identifier][name] = options || {}

        self._attribute_definitions[self.identifier][name][:block] = block if block_given?
      end

      def attributes(*args)
        options = args.extract_options!

        args.each do |attribute|
          self.attribute(attribute, options)
        end
      end

      def attribute_definitions
        self._attribute_definitions[self.identifier] ||= {}
        self._attribute_definitions[self.identifier]
      end

      def with_options(options={}, &block)
        yield(DnzHarvester::Scope.new(self, options))
      end

      def custom_instance_methods
        self.instance_methods(false)
      end
    end

    def initialize(*args)
      @original_attributes = {}
      self.set_attribute_values
    end

    def set_attribute_values
      self.class.attribute_definitions.each do |name, options|
        value = attribute_value(options, document)
        value = split_value(value, options[:separator]) if options[:separator]
        @original_attributes[name] ||= nil
        @original_attributes[name] = value if value.present?
      end
    end

    def attribute_value(options={}, document=nil)
      return options[:default] if options[:default]
      return get_value_from(options[:from]) if options[:from]
      return DnzHarvester::ConditionalOption.new(document, options).value if options[:xpath] && options[:if]
      return DnzHarvester::MappingOption.new(document, options).value if options[:xpath] && options[:mappings]
      return DnzHarvester::XpathOption.new(document, options).value if options[:xpath]
    end

    def get_value_from(name)
      raise NotImplementedError.new("All subclasses of DnzHarvester::Base must override #get_value_from.")
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
        instance_eval(&block)
      elsif self.class.custom_instance_methods.include?(name)
        self.send(name)
      else
        original_attributes[name]
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