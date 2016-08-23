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
    class Joiner < AbstractModifier
        
      attr_reader :original_value, :joiner

      def initialize(original_value, joiner)
        @original_value = original_value
        @joiner = joiner.to_s
      end

      def modify
        [original_value.join(joiner)]
      end      
    end
  end
end
