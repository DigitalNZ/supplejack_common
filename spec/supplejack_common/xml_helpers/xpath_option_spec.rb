# The Supplejack Common code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack 

require "spec_helper"

describe SupplejackCommon::XpathOption do
  
  let(:document) { Nokogiri.parse("<?xml version=\"1.0\" ?><items><item><title>Hi</title></item></items>") }
  let(:options) { {xpath: "table/tr"} }
  let(:xo) { SupplejackCommon::XpathOption.new(document, options) }

  describe "#value" do
    let(:nodes) { mock(:nodes, to_html: "<br>Value<br>") }
    before { xo.stub(:nodes) { nodes } }

    it "returns the sanitized html from the nodes" do
      xo.value.should eq "Value"
    end

    it "returns the sanitized html from an array of NodeSets" do
      xo.stub(:nodes) { [mock(:node_set, to_html: "Value")] }
      xo.value.should eq ["Value"]
    end

    it "returns the node object" do
      xo.stub(:options) { {xpath: "table/tr", object: true} }
      xo.value.should eq nodes
    end

    it "lets you specify what elements not to sanitize" do
      xo.stub(:options){{sanitize_config: {elements: ['br']}}}
      expect(xo.value).to eq("<br>Value<br>")
    end

    it "does not encode special entities" do
      node = mock(:nodes, to_html: "Test & Test")
      xo.stub(:nodes) {node}

      expect(xo.value).to eq("Test & Test")
    end
  end

  describe "#xpath_value" do
    it "appends a dot when document is a NodeSet" do
      xo.stub(:document) { document.xpath("//items/item") }
      xo.send(:xpath_value, "//title").should eq ".//title"
    end

    it "appends a dot when document is a Element" do
      xo.stub(:document) { document.xpath("//items/item").first }
      xo.send(:xpath_value, "//title").should eq ".//title"
    end

    it "returns the same xpath for a full document" do
      xo.stub(:document) { document }
      xo.send(:xpath_value, "//title").should eq "//title"
    end
  end

  describe "#initialize" do
    it "assigns the document and options" do
      xo.document.should eq document
      xo.options.should eq options
    end
  end

  describe "#nodes" do
    let(:node) { mock(:node) }

    it "finds the nodes specified by the xpath string" do
      document.should_receive(:xpath).with("table/tr", {}).and_return([node])
      xo.send(:nodes).should eq [node]
    end

    it "returns all matching nodes for the multiple xpath expressions" do
      xo.stub(:options) { {xpath: ["//table/tr", "//div/img"]} }
      document.should_receive(:xpath).with("//table/tr", {}).and_return([node])
      document.should_receive(:xpath).with("//div/img", {}).and_return([node])
      xo.send(:nodes).should eq [node, node]
    end

    it "returns a empty array when xpath is not defined" do
      xo.stub(:options) { {xpath: ""} }
      xo.send(:nodes).should eq []
    end

    it "should add all namespaces to the xpath query" do
      xo = SupplejackCommon::XpathOption.new(document, {xpath: "//dc:id"}, {dc: "http://goo.gle/", xsi: "http://yah.oo"})
      document.should_receive(:xpath).with("//dc:id", {dc: "http://goo.gle/", xsi: "http://yah.oo"}).and_return([node])
      xo.send(:nodes).should eq [node]
    end
  end
end
