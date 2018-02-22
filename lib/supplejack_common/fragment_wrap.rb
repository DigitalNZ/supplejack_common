module SupplejackCommon
	# FragmentWrap
  class FragmentWrap
    
    attr_reader :fragment

    def initialize(fragment)
      @fragment = fragment
    end

    def [](attribute)
      SupplejackCommon::AttributeValue.new(fragment.attributes[attribute.to_s])
    end
  end
end
