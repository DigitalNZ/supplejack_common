# The Supplejack code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack_core 

module HarvesterCore
  module Modifiers
    class Rejector < AbstractModifier
        
      attr_reader :original_value, :regex

      def initialize(original_value, regex)
        @original_value = Array(original_value)
        @regex = regex.to_s
      end

      def modify
        original_value.reject_if { |v| v.match }
      end
      
    end
  end
end