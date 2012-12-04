module DnzHarvester
  class Base
    include DnzHarvester::Filters::Finders
    include DnzHarvester::Filters::Modifiers

    class_attribute :_base_urls
    class_attribute :_attribute_definitions

    self._base_urls = []
    self._attribute_definitions = {}

    attr_reader :original_attributes

    class << self
      def base_url(url)
        self._base_urls << url
      end

      def base_urls
        self._base_urls
      end

      def attribute(name, options={})
        self._attribute_definitions[name] = options || {}
      end

      def attributes(*args)
        options = args.pop if args.last.is_a?(Hash)

        args.each do |attribute|
          self.attribute(attribute, options)
        end
      end

      def attribute_definitions
        self._attribute_definitions
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

      (@original_attributes.keys - self.class.custom_instance_methods).each do |method_name|
        self.class.send(:define_method, method_name, lambda { @original_attributes[method_name] })
      end
    end

    def set_attribute_values
      self.class._attribute_definitions.each do |name, options|
        @original_attributes[name] = options[:default] if options[:default].present?
      end
    end

    def attributes
      modified_attributes = {}

      attribute_names.each do |name|
        modified_attributes[name] = self.send(name)
      end

      modified_attributes
    end

    def attribute_names
      self.class._attribute_definitions.keys + self.class.custom_instance_methods
    end

    def to_s
      "=> #<#{self.class.to_s} @original_attributes=#{@original_attributes.inspect}>"
    end

    def method_missing(symbol, *args, &block)
      raise NoMethodError, "undefined method '#{symbol.to_s}' for #{self.class.to_s}" unless @original_attributes.has_key?(symbol)
      @original_attributes[symbol]
    end
  end
end