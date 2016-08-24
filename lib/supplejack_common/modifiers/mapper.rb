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
    class Mapper < AbstractModifier
      attr_reader :regexp, :replacement_rules

      def initialize(original_value, replacement_rules = {})
        @original_value = original_value.map(&:dup)
        @replacement_rules = replacement_rules
      end

      def modify
        values = original_value.map do |value|
          replacement_rules.each do |regexp, substitute_value|
            value = value.gsub(regexp, substitute_value)
          end
          value
        end.compact

        values
      end
    end
  end
end
