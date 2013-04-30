require "spec_helper"

describe HarvesterCore::XmlDslMethods do

  let(:klass) { HarvesterCore::Xml::Base }
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
      record.fetch("//item").should be_a HarvesterCore::AttributeValue
    end

    it "should be backwards compatible with xpath option" do
      record.fetch(xpath: "//item").to_a.should eq ["1", "2"]
    end

    it "should fetch a value with a namespace" do
      klass.namespaces dc: "http://purl.org/dc/elements/1.1/"
      record.stub(:document) { Nokogiri.parse(%q{<doc><dc:item xmlns:dc="http://purl.org/dc/elements/1.1/">1</dc:item></doc>}) }
      record.fetch("//dc:item", "dc").to_a.should eq ["1"]
    end
  end
  
  describe "#node" do
    let(:document) { Nokogiri::XML::Document.new }
    let(:xml_nodes) { mock(:xml_nodes) }

    before { record.stub(:document) { document } }

    it "extracts the XML nodes from the document" do
      document.should_receive(:xpath).with("//locations", {}) { xml_nodes }
      record.node("//locations").should eq xml_nodes
    end

    it "should fetch a node with a name space" do
       klass.namespaces dc: "http://purl.org/dc/elements/1.1/", xsi: "xsiid"
       document.should_receive(:xpath).with("//locations", {:dc => "http://purl.org/dc/elements/1.1/", :xsi => "xsiid"}) { xml_nodes }
       record.node("//locations", namespaces: ["dc", "xsi"])
    end

    context "xml document not available" do
      before { record.stub(:document) {nil} }

      it "returns an empty attribute_value" do
        nodes = record.node("//locations", {})
        nodes.should be_a(HarvesterCore::AttributeValue)
        nodes.to_a.should eq []
      end
    end
  end

  describe ".get_namespaces" do
    it "return a hash of the namespaces specified" do
      klass.namespaces dc: "http://purl.org/dc/elements/1.1/", xsi: "xsiid"
      klass.send(:get_namespaces, [:dc]).should eq({:dc => "http://purl.org/dc/elements/1.1/"})
    end

    it "returns an empty hash when passed nil" do
      klass.send(:get_namespaces, nil).should eq({})
    end
  end
end