# The Supplejack Common code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack 

module SupplejackCommon
  module Oai
    class PaginatedCollection < SupplejackCommon::PaginatedCollection

      include Enumerable

      attr_reader :client, :options, :klass, :limit
          
      def initialize(client, options, klass)
        @client = client
        @limit = options.delete(:limit)
        @options = options
        @klass = klass
        @counter = 0
      end

      def each
        client.list_records(options).full.each do |oai_record|
          record = klass.new(oai_record)
          record.set_attribute_values

          if record.rejected?
            next
          else
            yield(record)
            @counter += 1
          end
          break if limit.present? && limit == @counter
        end
      end
    end
  end
end