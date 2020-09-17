# frozen_string_literal: true

module SupplejackCommon
  # Enrichment Class
  class Enrichment < AbstractEnrichment
    # Internal attribute accessors
    attr_accessor :_url, :_format, :_namespaces, :_attribute_definitions,
                  :_required_attributes, :_rejection_rules, :_http_headers,
                  :_proxy

    attr_reader :block

    def initialize(name, options, record, parser_class)
      super
      @block = options[:block]
      @_attribute_definitions = {}
      @_required_attributes = {}
      @_rejection_rules = {}
      instance_eval(&block)
    end

    def url(url)
      self._url = url
    end

    def identifier
      "#{@parser_class.name.underscore}_#{name}"
    end

    def reject_if(&block)
      _rejection_rules[identifier] = block
    end

    def format(format)
      self._format = format.to_sym
    end

    def requires(name, &block)
      _required_attributes[name] = begin
                                     instance_eval(&block)
                                   rescue StandardError
                                     nil
                                   end
    end

    def requirements
      _required_attributes
    end

    def namespaces(namespaces = {})
      self._namespaces = namespaces
    end

    # This takes a hash of HTTP headers
    # eg { 'Authorization': 'something', 'api-key': 'somekey' }
    def http_headers(headers)
      self._http_headers = headers
    end

    def proxy(url)
      self._proxy = url
    end

    def attribute(name, options = {}, &block)
      _attribute_definitions[name] = options || {}
      _attribute_definitions[name][:block] = block if block_given?
    end

    # rubocop:disable Metrics/AbcSize
    def resource
      resource_class = "SupplejackCommon::#{_format.to_s.capitalize}Resource".constantize
      options = {}
      options[:attributes] = attributes if attributes.present?
      options[:attributes][:requirements] = requirements if requirements.any?
      options[:throttling_options] = parser_class._throttle if parser_class._throttle.present?
      options[:namespaces] = _namespaces if _namespaces.present?
      options[:http_headers] = _http_headers if _http_headers.present?
      options[:request_timeout] = parser_class._request_timeout if parser_class._request_timeout.present?
      options[:proxy] = _proxy if _proxy.present?
      @resource ||= resource_class.new(_url, options)
    end
    # rubocop:enable Metrics/AbcSize

    def set_attribute_values
      _attribute_definitions.each do |name, options|
        builder = AttributeBuilder.new(resource, name, options)
        value = builder.value
        attributes[name] ||= nil
        if builder.errors.any?
          errors[name] = builder.errors
        else
          attributes[name] = value if value.present?
        end
      end
    end

    def enrichable?
      _required_attributes.each do |_attribute, value|
        return false if value.nil?
      end

      rejection_block = _rejection_rules[identifier]

      return true if rejection_block.nil?
      !instance_eval(&rejection_block)
    end
  end
end
