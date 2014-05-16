# The Supplejack code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack_core 

require "spec_helper"

describe HarvesterCore::XmlDataMethods do

	let(:klass) { HarvesterCore::Xml::Base }
	let(:record) { klass.new("http://google.com") }

	describe "full_raw_data" do
	  before { record.stub(:raw_data) { "<record/>" } }

	  context "with namespaces" do
	    before { klass._namespaces = {"xmlns:foo" => "bar" } }

	    it "should add the root node with namespaces" do
	      record.full_raw_data.should eq "<root xmlns:foo='bar'><record/></root>"
	    end
	  end

	  context "without namespaces" do
	    before { klass._namespaces = nil }

	    it "should return the raw_data" do
	      record.full_raw_data.should eq "<record/>"
	    end
	  end
	end
end