# frozen_string_literal: true

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
