require "spec_helper"

describe DnzHarvester::XpathOption do
  
  let(:document) { mock(:document) }
  let(:options) { {xpath: "table/tr"} }
  let(:xo) { DnzHarvester::XpathOption.new(document, options) }

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
end