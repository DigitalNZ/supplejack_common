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
  end
end