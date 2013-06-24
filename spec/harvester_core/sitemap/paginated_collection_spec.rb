require "spec_helper"

describe HarvesterCore::Sitemap::PaginatedCollection do

	class TestXml < HarvesterCore::Xml::Base; end

	let(:collection) { HarvesterCore::Sitemap::PaginatedCollection.new(TestXml) }
	let(:document) { mock(:document) }
	let(:sitemap_klass) { HarvesterCore::Sitemap::Base }

	it "initializes the klass, sitemap_klass with a sitemap_entry_selector and options" do
		collection = HarvesterCore::Sitemap::PaginatedCollection.new(TestXml)
		collection.klass.should eq TestXml
		collection.sitemap_klass.should eq sitemap_klass
		collection.options.should eq({})
  end

  it "calls sitemap_entry_selector on sitemap_klass with the selector passed through" do
  	TestXml.sitemap_entry_selector "//loc"
  	collection.sitemap_klass.should_receive(:sitemap_entry_selector).with("//loc")
    collection = HarvesterCore::Sitemap::PaginatedCollection.new(TestXml)
  end

  it "adds the namespaces to the site" do
    TestXml.namespaces page: 'http://www.w3.org/1999/xhtml'
    collection.sitemap_klass.should_receive(:_namespaces=).with(page: 'http://www.w3.org/1999/xhtml')
    collection = HarvesterCore::Sitemap::PaginatedCollection.new(TestXml)
  end

	describe "#each" do

		before do
			TestXml.stub(:base_urls) { ["http://goog.le"] }
			TestXml.stub(:fetch_records) { "<xml>1<xml>" }
			collection.stub(:yield_from_records) { true }
		end

		it "fetches the entries from the site map" do
		  sitemap_klass.should_receive(:fetch_entries).with("http://goog.le") { ["http://goo.gl/1.xml", "http://goo.gl/2.xml"] }
		  collection.each {|record|}
		  collection.instance_variable_get(:@entries).should eq ["http://goo.gl/1.xml", "http://goo.gl/2.xml"]
		end

		it "fetches the records for the provided strategy then stores them in @records" do
			xml_1 = mock(:text_xml)
			xml_2 = mock(:text_xml)
			sitemap_klass.stub(:fetch_entries) { ["http://goo.gl/1.xml"] }
			TestXml.should_receive(:fetch_records).with("http://goo.gl/1.xml") { [xml_1, xml_2]  }
			collection.each {|record|}
			collection.instance_variable_get(:@records).should include(xml_1, xml_2)
		end

		it "calls yield from records for each entry" do
			collection.should_receive(:yield_from_records).twice
		  sitemap_klass.stub(:fetch_entries) { ["http://goo.gl/1.xml", "http://goo.gl/2.xml"] }
		  collection.each {|record|}
		end

		context "multiple base urls" do

			before do 
				TestXml.stub(:base_urls) { ["http://goog.le", "http://dnz.com/1"] }
				collection.stub(:entries) { [] }
			end


			it "handles multiple sitemap base_urls" do
			  HarvesterCore::Sitemap::Base.should_receive(:fetch_entries).with("http://goog.le") { [] }
			  HarvesterCore::Sitemap::Base.should_receive(:fetch_entries).with("http://dnz.com/1"){ []}
			  collection.each {|record|}
			end
		end
	end
end