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
      xo = HarvesterCore::XpathOption.new(document, {xpath: "//dc:id"}, {dc: "http://goo.gle/", xsi: "http://yah.oo"})
      document.should_receive(:xpath).with("//dc:id", {dc: "http://goo.gle/", xsi: "http://yah.oo"}).and_return([node])
      xo.send(:nodes).should eq [node]
    end
  end
end