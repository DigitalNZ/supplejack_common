module DnzHarvester
  module Oai
    class PaginatedCollection < DnzHarvester::PaginatedCollection

      include Enumerable

      attr_reader :client, :options, :klass, :limit
          
      def initialize(client, options, klass)
        @client = client
        @options = options
        @klass = klass
        @limit = @options.delete(:limit)
        @counter = 0
        @records = []
      end

      def each
        client.list_records(options).each do |oai_record|
          record = klass.new(oai_record)
          yield(record)
          @counter += 1
          @records << record
          return @records if limit && limit == @counter
        end
        return @records
      end
    end
  end
end