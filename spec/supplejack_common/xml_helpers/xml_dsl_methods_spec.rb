# The Supplejack Common code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack 

require "spec_helper"

describe SupplejackCommon::XmlDslMethods do

  let(:klass) { SupplejackCommon::Xml::Base }
  let(:record) { klass.new("http://google.com") }

  describe "#fetch" do
    let(:document) { Nokogiri.parse("<doc><item>1</item><item>2</item></doc>") }

    before do
      record.stub(:document) { document }
    end

    it "should fetch a xpath result from the document" do
      record.fetch("//item").to_a.should eq ["1", "2"]
    end

    it "should return a AttributeValue" do
      record.fetch("//item").should be_a SupplejackCommon::AttributeValue
    end

    it "should be backwards compatible with xpath option" do
      record.fetch(xpath: "//item").to_a.should eq ["1", "2"]
    end

    it "should fetch a value with a namespace" do
      klass.namespaces dc: "http://purl.org/dc/elements/1.1/"
      record.stub(:document) { Nokogiri.parse(%q{<doc><dc:item xmlns:dc="http://purl.org/dc/elements/1.1/">1</dc:item></doc>}) }
      record.fetch("//dc:item").to_a.should eq ["1"]
    end
  end
  
  describe "#node" do
    let(:document) { Nokogiri::XML::Document.new }
    let(:xml_nodes) { mock(:xml_nodes) }

    before { record.stub(:document) { document } }

    it "extracts the XML nodes from the document" do
      document.should_receive(:xpath).with("//locations", anything) { xml_nodes }
      record.node("//locations").should eq xml_nodes
    end

    it "should use all the defined namespaces on the class" do
      klass.namespaces dc: "http://purl.org/dc/elements/1.1/"
      document.should_receive(:xpath).with("//dc:item", hash_including(dc: "http://purl.org/dc/elements/1.1/")) { xml_nodes }
      record.node("//dc:item").should eq xml_nodes
    end

    context "xml document not available" do
      before { record.stub(:document) {nil} }

      it "returns an empty attribute_value" do
        nodes = record.node("//locations")
        nodes.should be_a(SupplejackCommon::AttributeValue)
        nodes.to_a.should eq []
      end
    end
  end
end