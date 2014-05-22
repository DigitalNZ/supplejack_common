# The Supplejack Common code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack 

module SupplejackCommon
  class JsonResource < Resource
    
    def document
      @document ||= JSON.parse(fetch_document)
    end

    def strategy_value(options)
      options ||= {}
      path = options[:path]
      return nil unless path.present?

      if path.is_a?(Array)
        path.map {|p| document[p] }
      else
        document[path]
      end
    end

    def fetch(path)
      value = JsonPath.on(document, path)
      SupplejackCommon::AttributeValue.new(value)
    end

    def requirements
      self.attributes[:requirements]
    end
  end
end