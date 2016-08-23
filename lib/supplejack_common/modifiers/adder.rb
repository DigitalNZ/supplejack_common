# The Supplejack Common code is
# Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# See https://github.com/DigitalNZ/supplejack for details.
#
# Supplejack was created by DigitalNZ at the
# National Library of NZ and the Department of Internal Affairs.
# http://digitalnz.org/supplejack

module SupplejackCommon
  module Modifiers
    class Adder < AbstractModifier

      attr_reader :new_value

      def initialize(original_value, new_value)
        @original_value = original_value
        @new_value = new_value
      end

      def modify
        original_value + Array(new_value)
      end
    end
  end
end
