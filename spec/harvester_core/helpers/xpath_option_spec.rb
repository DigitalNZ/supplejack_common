require "spec_helper"

describe HarvesterCore::XpathOption do
  
  let(:document) { Nokogiri.parse("<?xml version=\"1.0\" ?><items><item><title>Hi</title></item></items>") }
  let(:options) { {xpath: "table/tr"} }
  let(:xo) { HarvesterCore::XpathOption.new(document, options) }

  describe "#value" do
    let(:nodes) { mock(:nodes, text: "Value") }
    before { xo.stub(:nodes) { nodes } }

    it "returns the text from the nodes" do
      xo.value.should eq "Value"
    end

    it "returns the text from a array of NodeSets" do
      xo.stub(:nodes) { [mock(:node_set, text: "Value")] }
      xo.value.should eq ["Value"]
    end

    it "returns the node object" do
      xo.stub(:options) { {xpath: "table/tr", object: true} }
      xo.value.should eq nodes
    end
  end

  describe "#xpath_value" do
    it "appends a dot when document is a NodeSet" do
      xo.stub(:document) { document.xpath("//items/item") }
      xo.xpath_value("//title").should eq ".//title"
    end

    it "appends a dot when document is a Element" do
      xo.stub(:document) { document.xpath("//items/item").first }
      xo.xpath_value("//title").should eq ".//title"
    end

    it "returns the same xpath for a full document" do
      xo.stub(:document) { document }
      xo.xpath_value("//title").should eq "//title"
    end
  end
end