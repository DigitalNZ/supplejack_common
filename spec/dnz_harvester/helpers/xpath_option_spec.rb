require "spec_helper"

describe DnzHarvester::XpathOption do
  
  let(:document) { mock(:document) }
  let(:options) { {xpath: "table/tr"} }
  let(:xo) { DnzHarvester::XpathOption.new(document, options) }

  describe "#value" do
    it "returns the text from the nodes" do
      xo.stub(:nodes) { mock(:nodes, text: "Value") }
      xo.value.should eq "Value"
    end

    it "returns the text from a array of NodeSets" do
      xo.stub(:nodes) { [mock(:node_set, text: "Value")] }
      xo.value.should eq ["Value"]
    end
  end
end