module HarvesterCore
  class Enrichment

    attr_accessor :_url, :_format, :_namespaces, :_attribute_definitions, :errors
    attr_reader :name, :block, :record, :attributes

    def initialize(name, block, record)
      @name = name
      @block = block
      @record = record
      @attributes = {}
      @errors = {}
      @_attribute_definitions = {}
      self.instance_eval(&block)
    end

    def url(url)
      self._url = url
    end

    def format(format)
      self._format = format.to_sym
    end

    def namespaces(namespaces={})
      self._namespaces = namespaces
    end

    def attribute(name, options={}, &block)
      self._attribute_definitions[name] = options || {}
      self._attribute_definitions[name][:block] = block if block_given?
    end

    def resource
      resource_class = "HarvesterCore::#{_format.to_s.capitalize}Resource".constantize
      options = {}
      options[:throttling_options] = record.class._throttle if record.class._throttle.present?
      options[:namespaces] = self._namespaces if self._namespaces.present?
      @resource ||= resource_class.new(self._url, options)
    end

    def set_attribute_values
      self._attribute_definitions.each do |name, options|
        builder = AttributeBuilder.new(resource, name, options)
        value = builder.value
        @attributes[name] ||= nil
        if builder.errors.any?
          self.errors[name] = builder.errors
        else
          @attributes[name] = value if value.present?
        end
      end
    end
  end
end