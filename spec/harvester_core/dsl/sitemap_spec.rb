# The Supplejack code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack_core 

require 'spec_helper'

class TestXmlParser < HarvesterCore::Xml::Base; end

describe HarvesterCore::Dsl::Sitemap do
	let(:klass) { TestXmlParser }
	
	describe ".sitemap_entry_selector" do
		it "should set the sitemap entry selector" do
		  klass.sitemap_entry_selector("//loc")
		  klass._sitemap_entry_selector.should eq "//loc"
		end
	end
end