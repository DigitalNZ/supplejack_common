require "spec_helper"

describe DnzHarvester::AbstractOption do
  
  let(:document) { mock(:document) }
  let(:options) { {xpath: "//table/tr"} }
  let(:ao) { DnzHarvester::AbstractOption.new(document, options) }

  describe "#initialize" do
    it "assigns the document and options" do
      ao.document.should eq document
      ao.options.should eq options
    end
  end

  describe "#nodes" do
    let(:node) { mock(:node) }

    it "finds the nodes specified by the xpath string" do
      document.should_receive(:xpath).with("//table/tr").and_return([node])
      ao.nodes.should eq [node]
    end

    it "returns all matching nodes for the multiple xpath expressions" do
      ao.stub(:options) { {xpath: ["//table/tr", "//div/img"]} }
      document.should_receive(:xpath).with("//table/tr").and_return([node])
      document.should_receive(:xpath).with("//div/img").and_return([node])
      ao.nodes.should eq [node, node]
    end

    it "returns a empty array when xpath is not defined" do
      ao.stub(:options) { {xpath: ""} }
      ao.nodes.should eq []
    end
  end
end