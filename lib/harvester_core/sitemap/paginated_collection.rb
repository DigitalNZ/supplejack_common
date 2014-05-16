# The Supplejack code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack_core 

module HarvesterCore
  module Sitemap
    class PaginatedCollection < HarvesterCore::PaginatedCollection

    	attr_reader :klass, :sitemap_klass, :options

    	def initialize(klass, pagination_options={}, options={})
    		super
        @sitemap_klass = HarvesterCore::Sitemap::Base
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
  		      unless yield_from_records(&block)
  		        return nil
  		      end
      		end
        end
    	end
    
    end
  end
end