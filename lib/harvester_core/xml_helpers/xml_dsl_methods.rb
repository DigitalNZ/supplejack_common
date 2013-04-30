module HarvesterCore
  module XmlDslMethods
    extend ::ActiveSupport::Concern

    included do
      class_attribute :_namespaces
    end

    def fetch(xpath, namespaces=[])
      xpath = xpath[:xpath] if xpath.is_a?(Hash)
      values = HarvesterCore::XpathOption.new(self.document, {xpath: xpath, namespaces: namespaces}, self.class._namespaces).value
      HarvesterCore::AttributeValue.new(values)
    end

    def node(xpath, options={})
      if self.document
        self.document.xpath(xpath, self.class.get_namespaces(options[:namespaces]))
      else
        HarvesterCore::AttributeValue.new(nil)
      end
    end

    def strategy_value(options={})
      return HarvesterCore::ConditionalOption.new(self.document, options, self.class._namespaces).value if options[:xpath] && options[:if]
      return HarvesterCore::XpathOption.new(self.document, options, self.class._namespaces).value if options[:xpath]
    end

    module ClassMethods
      def namespaces(namespaces={})
        self._namespaces ||= {}
        self._namespaces.merge!(namespaces)
      end

      def get_namespaces(namespaces)
        self._namespaces.present? ? self._namespaces.select{ |k,v| Array(namespaces).map(&:to_sym).include? k } : {}
      end
    end
  end
end