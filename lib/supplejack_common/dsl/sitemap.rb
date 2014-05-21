# The Supplejack Common code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack 

module SupplejackCommon
	module Dsl
		module Sitemap
			extend ActiveSupport::Concern

			included do
				class_attribute :_sitemap_entry_selector
			end

			module ClassMethods
				def sitemap_entry_selector(xpath)
	    	  self._sitemap_entry_selector = xpath
	    	end
			end

		end
	end
end