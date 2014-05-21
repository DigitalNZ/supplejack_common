# The Supplejack Common code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack 

module SupplejackCommon
  module Modifiers
    class FinderWith < AbstractModifier

      attr_reader :original_value, :regexp, :scope

      def initialize(original_value, regexp, scope=:first)
        @original_value, @regexp, @scope = original_value, regexp, scope
      end

      def modify
        finder_method = scope == :first ? :find : :find_all
        Array(original_value.send(finder_method) {|c| c.to_s.match(regexp) })
      end
    end
  end
end