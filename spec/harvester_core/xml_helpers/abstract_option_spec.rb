require "spec_helper"

describe HarvesterCore::AbstractOption do
  
  let(:document) { mock(:document) }
  let(:options) { {xpath: "//table/tr"} }
  let(:ao) { HarvesterCore::AbstractOption.new(document, options) }

  describe "#initialize" do
    it "assigns the document and options" do
      ao.document.should eq document
      ao.options.should eq options
    end
  end

  describe "#nodes" do
    let(:node) { mock(:node) }

    it "finds the nodes specified by the xpath string" do
      document.should_receive(:xpath).with("//table/tr", nil).and_return([node])
      ao.nodes.should eq [node]
    end

    it "returns all matching nodes for the multiple xpath expressions" do
      ao.stub(:options) { {xpath: ["//table/tr", "//div/img"]} }
      document.should_receive(:xpath).with("//table/tr", nil).and_return([node])
      document.should_receive(:xpath).with("//div/img", nil).and_return([node])
      ao.nodes.should eq [node, node]
    end

    it "returns a empty array when xpath is not defined" do
      ao.stub(:options) { {xpath: ""} }
      ao.nodes.should eq []
    end

    it "should add namespaces to the xpath query" do
      ao = HarvesterCore::AbstractOption.new(document, {xpath: "//dc:id", namespaces: ["dc"]}, {dc: "http://goo.gle/", xsi: "http://yah.oo"})
      document.should_receive(:xpath).with("//dc:id", {dc: "http://goo.gle/"}).and_return([node])
      ao.nodes.should eq [node]
    end
  end

  describe "#namespace" do
    it "returns a namespace hash with the specified namespaces" do
      ao = HarvesterCore::AbstractOption.new(document, {xpath: "//dc:id", namespaces: ["dc"]}, {dc: "http://goo.gle/"})
      ao.namespace.should eq({dc: "http://goo.gle/"})
    end

    it "should not return namespaces not included" do
      ao = HarvesterCore::AbstractOption.new(document, {xpath: "//dc:id", namespaces: ["dc"]}, {dc: "http://goo.gle/", xsi: "http://yah.oo"})
      ao.namespace.should_not include({xsi: "http://yah.oo"})
    end

    it "returns nil when no namespaces are defined" do
      ao = HarvesterCore::AbstractOption.new(document, {xpath: "//dc:id", namespaces: []}, {dc: "http://goo.gle/", xsi: "http://yah.oo"})
      ao.namespace.should be_nil
    end
  end
end