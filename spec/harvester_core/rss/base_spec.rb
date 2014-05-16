# The Supplejack code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack_core 

require 'spec_helper'

describe HarvesterCore::Rss::Base do

  let(:klass) { HarvesterCore::Rss::Base }

  describe ".records" do
    it "returns a paginated collection" do
      HarvesterCore::PaginatedCollection.should_receive(:new).with(klass, {}, {})
      klass.records
    end
  end

  describe "fetch_records" do
    let(:doc) { double(:nokogiri).as_null_object }
    let(:node) { double(:node).as_null_object }
    let(:url) { "http://goo.gle" }

    before(:each) do
      klass.stub(:index_document) { doc }
      klass._namespaces = {dc: 'http://dc.com'}
      doc.stub(:xpath).with("//item", anything) { [node] }
    end

    it "splits the xml into nodes for each RSS entry" do
      doc.should_receive(:xpath).with("//item", anything) { [node] }
      klass.fetch_records(url)
    end

    it "initializes a record with the RSS entry node" do
      klass.should_receive(:new).with(node)
      klass.fetch_records(url)
    end
  end

  describe "#initialize" do
    let(:xml) { "<record><title>Hi</title></record>" }
    let(:node) { double(:node, to_xml: xml ).as_null_object }

    it "initializes the record from xml" do
      record = klass.new(xml)
      record.original_xml.should eq xml
    end

    it "intializes the record from a node" do
      record = klass.new(node)
      record.original_xml.should eq xml
    end
  end


  describe "#document" do
    let(:xml) { "<record><title>Hi</title></record>" }
    let(:record) { klass.new(xml) }
    let(:document) { double(:document).as_null_object }

    it "should parse the xml with Nokogiri" do
      Nokogiri::XML.should_receive(:parse).with(xml) { document }
      record.document.should eq document
    end
  end
end