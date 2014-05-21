# The Supplejack Common code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack_core 

module SupplejackCommon
  module Modifiers
    class Truncator < AbstractModifier

      attr_reader :original_value, :length, :omission

      def initialize(original_value, length, omission="...")
        @original_value = original_value
        @length = length.to_i
        @omission = omission.to_s
      end

      def modify
        original_value.map do |value|
          value.is_a?(String) ? value.truncate(length, omission: omission) : value
        end
      end
    end
  end
end