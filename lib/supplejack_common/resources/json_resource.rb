

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