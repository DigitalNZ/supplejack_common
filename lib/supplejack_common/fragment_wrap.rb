# The Supplejack Common code is
# Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# See https://github.com/DigitalNZ/supplejack for details.
#
# Supplejack was created by DigitalNZ at the
# National Library of NZ and the Department of Internal Affairs.
# http://digitalnz.org/supplejack

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
