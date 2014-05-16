# The Supplejack code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack_core 

module HarvesterCore
  module Modifiers
    class AbstractModifier
      
      attr_reader :original_value

      def initialize(original_value)
        @original_value = original_value
      end

      def modify
        raise NotImplementedError.new("All subclasses of HarvesterCore::Modifiers::AbstractModifier must override #modify.")
      end

      def value
        AttributeValue.new(self.modify)
      end
    end
  end
end