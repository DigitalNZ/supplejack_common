require 'spec_helper'

describe HarvesterCore::Rss::Base do

  let(:klass) { HarvesterCore::Rss::Base }

  describe ".records" do
    let(:record) { mock(:record).as_null_object }

    before do
      klass.stub(:xml_records) { [record, record] }
    end

    it "limits the records to 1" do
      klass.records(limit: 1).size.should eq 1
    end
  end

  describe "xml_records" do
    let(:doc) { mock(:nokogiri).as_null_object }
    let(:node) { mock(:node).as_null_object }

    before(:each) do
      klass.stub(:index_document) { doc }
      doc.stub(:xpath).with("//item") { [node] }
    end

    it "splits the xml into nodes for each RSS entry" do
      doc.should_receive(:xpath).with("//item") { [node] }
      klass.xml_records
    end

    it "initializes a record with the RSS entry node" do
      klass.should_receive(:new).with(node)
      klass.xml_records
    end
  end

  describe "#initialize" do
    let(:xml) { "<record><title>Hi</title></record>" }
    let(:node) { mock(:node, to_xml: xml ).as_null_object }

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
    let(:document) { mock(:document).as_null_object }

    it "should parse the xml with Nokogiri" do
      Nokogiri::XML.should_receive(:parse).with(xml) { document }
      record.document.should eq document
    end
  end
end