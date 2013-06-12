module HarvesterCore
  module Sitemap
    class PaginatedCollection < HarvesterCore::PaginatedCollection

    	attr_reader :klass, :sitemap_klass, :options

    	def initialize(klass, pagination_options={}, options={})
    		super
        @sitemap_klass = HarvesterCore::Sitemap::Base
        @sitemap_klass.sitemap_entry_selector(@klass._sitemap_entry_selector)
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
  		      unless yield_from_records(&block)
  		        return nil
  		      end
      		end
        end
    	end
    
    end
  end
end