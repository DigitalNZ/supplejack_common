# The Supplejack Common code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack 

module SupplejackCommon
  module Modifiers
    class Splitter < AbstractModifier

      attr_reader :original_value, :split_value

      def initialize(original_value, split_value)
        @original_value, @split_value = original_value, split_value
      end

      def modify
        original_value.map do |value|
          value.split(split_value)
        end.flatten
      end
    end
  end
end