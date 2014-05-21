# The Supplejack Common code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack 

module SupplejackCommon
  module Sitemap
    class Base < SupplejackCommon::Base
    	include SupplejackCommon::XmlDocumentMethods

    	self.clear_definitions

    	class_attribute :_record_selector
    	class_attribute :_namespaces

    	class << self
    		def fetch_entries(url=nil)
    			xml_records(url).map(&:entry_url)
    		end

    		def sitemap_entry_selector(xpath)
	    	  self._record_selector = xpath
	    	end

	    	def clear_definitions
	    		super
	    		self._record_selector = nil
	    	end
	    end

		  def initialize(node, url)
	      @node = node
	      super
	    end

	    def entry_url
	    	@node.text
	    end
    end
  end
end