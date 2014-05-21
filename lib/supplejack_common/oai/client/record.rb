# The Supplejack Common code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack_core 

module OAI
  class Record

    attr_accessor :element

    def initialize(element)
      @element = element
      @header = OAI::Header.new xpath_first(element, './/header')
      @metadata = xpath_first(element, './/metadata')
      @about = xpath_first(element, './/about')
    end
  end
end
