# The Supplejack Common code is
# Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# See https://github.com/DigitalNZ/supplejack for details.
#
# Supplejack was created by DigitalNZ at the
# National Library of NZ and the Department of Internal Affairs.
# http://digitalnz.org/supplejack

module SupplejackCommon
  # Enrichment Class
  class Enrichment < AbstractEnrichment
    # Internal attribute accessors
    attr_accessor :_url, :_format, :_namespaces, :_attribute_definitions, :_required_attributes, :_rejection_rules

    attr_reader :block

    def initialize(name, options, record, parser_class)
      super
      @block = options[:block]
      @_attribute_definitions = {}
      @_required_attributes = {}
      @_rejection_rules = {}
      self.instance_eval(&block)
    end

    def url(url)
      self._url = url
    end

    def identifier
      "#{@parser_class.name.underscore}_#{name}"
    end

    def reject_if(&block)
      self._rejection_rules[self.identifier] = block
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

    def namespaces(namespaces = {})
      self._namespaces = namespaces
    end

    def attribute(name, options = {}, &block)
      self._attribute_definitions[name] = options || {}
      self._attribute_definitions[name][:block] = block if block_given?
    end

    def resource
      resource_class = "SupplejackCommon::#{_format.to_s.capitalize}Resource".constantize
      options = {}
      options[:attributes] = self.attributes if self.attributes.present?
      options[:attributes][:requirements] = requirements if requirements.any?
      options[:throttling_options] = parser_class._throttle if parser_class._throttle.present?
      options[:namespaces] = self._namespaces if self._namespaces.present?
      options[:request_timeout] = parser_class._request_timeout if parser_class._request_timeout.present?
      @resource ||= resource_class.new(self._url, options)
    end

    def set_attribute_values
      self._attribute_definitions.each do |name, options|
        builder = AttributeBuilder.new(resource, name, options)
        value = builder.value
        attributes[name] ||= nil
        if builder.errors.any?
          self.errors[name] = builder.errors
        else
          attributes[name] = value if value.present?
        end
      end
    end

    def enrichable?
      self._required_attributes.each do |attribute, value|
        return false if value.nil?
      end

      rejection_block = self._rejection_rules[self.identifier]

      return true if rejection_block.nil?
      return !self.instance_eval(&rejection_block)
    end
  end
end
