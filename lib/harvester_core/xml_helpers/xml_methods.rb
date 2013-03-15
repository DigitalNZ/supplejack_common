module HarvesterCore
  module XmlMethods
    extend ::ActiveSupport::Concern

    included do
      class_attribute :_namespaces
    end

    def fetch(xpath)
      xpath = xpath[:xpath] if xpath.is_a?(Hash)
      values = HarvesterCore::XpathOption.new(self.document, xpath: xpath).value
      HarvesterCore::AttributeValue.new(values)
    end

    def node(xpath)
      if self.document
        self.document.xpath(xpath)
      else
        HarvesterCore::AttributeValue.new(nil)
      end
    end

    def strategy_value(options={})
      return HarvesterCore::ConditionalOption.new(self.document, options).value if options[:xpath] && options[:if]
      return HarvesterCore::XpathOption.new(self.document, options).value if options[:xpath]
    end

    def raw_data
      @raw_data ||= self.document.to_xml
    end

    def full_raw_data
      if self.class._namespaces.present?
        HarvesterCore::Utils.add_namespaces(raw_data, self.class._namespaces)
      else
        self.raw_data
      end
    end
  end
end