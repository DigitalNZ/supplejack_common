module HarvesterCore
  class Enrichment

    # Internal attribute accessors
    attr_accessor :_url, :_format, :_namespaces, :_attribute_definitions, :_required_attributes

    attr_accessor :errors
    attr_reader :name, :block, :record, :attributes

    def initialize(name, block, record)
      @name = name
      @block = block
      @record = record
      @attributes = {}
      @errors = {}
      @_attribute_definitions = {}
      @_required_attributes = {}
      self.instance_eval(&block)
    end

    def url(url)
      self._url = url
    end

    def format(format)
      self._format = format.to_sym
    end

    def requires(name, &block)
      self._required_attributes[name] = self.instance_eval(&block) rescue nil
    end

    def requirements
      self._required_attributes
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

    def primary
      #@primary ||= HarvesterCore::SourceWrap.new(record.sources.where(priority: 0).first)
      @primary ||= HarvesterCore::SourceWrap.new(record)
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

    def enrichable?
      self._required_attributes.each do |attribute, value|
        return false if value.blank?
      end
      true
    end
  end
end