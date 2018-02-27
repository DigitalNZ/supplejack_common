

module SupplejackCommon
  module XmlDslMethods
    extend ::ActiveSupport::Concern

    included do
      class_attribute :_namespaces
    end

    def fetch(xpath, namespaces=[], options = {})
      xpath = xpath[:xpath] if xpath.is_a?(Hash)
      values = SupplejackCommon::XpathOption.new(self.document, {xpath: xpath, namespaces: namespaces}.merge(options), self.class._namespaces).value
      SupplejackCommon::AttributeValue.new(values)
    end

    def node(xpath)
      if self.document
        self.document.xpath(xpath, self.class._namespaces)
      else
        SupplejackCommon::AttributeValue.new(nil)
      end
    end

    def strategy_value(options={})
      SupplejackCommon::XpathOption.new(self.document, options, self.class._namespaces).value if options[:xpath]
    end

    module ClassMethods
      def namespaces(namespaces={})
        self._namespaces ||= {}
        self._namespaces.merge!(namespaces)
      end
    end
  end
end
