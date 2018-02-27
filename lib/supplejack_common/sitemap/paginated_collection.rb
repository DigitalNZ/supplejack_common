# frozen_string_literal: true

module SupplejackCommon
  module Sitemap
    class PaginatedCollection < SupplejackCommon::PaginatedCollection
      attr_reader :klass, :sitemap_klass, :options

      def initialize(klass, pagination_options = {}, options = {})
        super
        @sitemap_klass = SupplejackCommon::Sitemap::Base
        @sitemap_klass.sitemap_entry_selector(@klass._sitemap_entry_selector)
        @sitemap_klass._namespaces = @klass._namespaces
      end

      def each(&block)
        @klass.base_urls.each do |base_url|
          @entries = @sitemap_klass.fetch_entries(next_url(base_url))
          @entries.each do |entry|
            begin
              @records = @klass.fetch_records(@klass.basic_auth_url(entry))
            rescue RestClient::Exception => e
              puts "EXCEPTION THROWN: #{e.message}"
              next
            end
            return nil unless yield_from_records(&block)
          end
        end
      end
    end
  end
end
