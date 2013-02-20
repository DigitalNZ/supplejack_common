module HarvesterCore
  module XmlMethods
    extend ::ActiveSupport::Concern

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
  end
end