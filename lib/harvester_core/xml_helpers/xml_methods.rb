module HarvesterCore
  module XmlMethods
    extend ::ActiveSupport::Concern

    included do
      class_attribute :_namespaces
    end

    def fetch(xpath)
      xpath = xpath[:xpath] if xpath.is_a?(Hash)
      values = HarvesterCore::XpathOption.new(document, xpath: xpath).value
      HarvesterCore::AttributeValue.new(values)
    end

    def node(xpath)
      if document
        document.xpath(xpath)
      else
        HarvesterCore::AttributeValue.new(nil)
      end
    end

    def strategy_value(options={}, document=nil)
      return HarvesterCore::ConditionalOption.new(document, options).value if options[:xpath] && options[:if]
      return HarvesterCore::XpathOption.new(document, options).value if options[:xpath]
    end

    def raw_data
      @raw_data ||= document.to_xml
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