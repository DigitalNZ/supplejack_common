# frozen_string_literal: true

module SupplejackCommon
  module Oai
    class PaginatedCollection < SupplejackCommon::PaginatedCollection
      include Enumerable

      attr_reader :client, :options, :klass, :limit, :channel_options

      def initialize(client, options, klass)
        @client = client
        @limit = options.delete(:limit)
        @options = options
        @klass = klass
        @counter = 0

        @channel_options = {
          user_id: options[:user_id],
          parser_id: options[:parser_id],
          environment: options[:environment]
        }
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
