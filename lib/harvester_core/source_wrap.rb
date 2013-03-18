module HarvesterCore
  class SourceWrap
    
    attr_reader :source

    def initialize(source)
      @source = source
    end

    def [](attribute)
      HarvesterCore::AttributeValue.new(source.attributes[attribute])
    end
  end
end