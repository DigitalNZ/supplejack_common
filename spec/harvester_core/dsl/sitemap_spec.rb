require 'spec_helper'

describe HarvesterCore::Dsl::Sitemap do
	let(:klass) { HarvesterCore::Xml::Base }
	
	describe ".sitemap_entry_selector" do
		it "should set the sitemap entry selector" do
		  klass.sitemap_entry_selector("//loc")
		  klass._sitemap_entry_selector.should eq "//loc"
		end
	end
end