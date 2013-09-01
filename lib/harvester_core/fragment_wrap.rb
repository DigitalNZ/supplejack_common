module HarvesterCore
  class FragmentWrap
    
    attr_reader :fragment

    def initialize(fragment)
      @fragment = fragment
    end

    def [](attribute)
      HarvesterCore::AttributeValue.new(fragment.attributes[attribute.to_s])
    end
  end
end