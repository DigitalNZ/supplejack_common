# The Supplejack code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack_core 

module HarvesterCore
  class XmlResource < Resource
    include HarvesterCore::XmlDslMethods

    def initialize(url, options={})
      super
      self.class.namespaces(options[:namespaces] || {})
    end
    
    def document
      @document ||= begin
        Nokogiri::XML.parse(fetch_document)
      end
    end

    def strategy_value(options)
      HarvesterCore::XpathOption.new(document, options, self.class._namespaces).value if options[:xpath]
    end
  end
end