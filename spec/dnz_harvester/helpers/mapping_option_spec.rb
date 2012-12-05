require "spec_helper"

describe DnzHarvester::MappingOption do
  
  let(:document) { mock(:document) }
  let(:options) { {xpath: "table/tr", mappings: {"Non commercial" => "CC-BY-NC", "Share" => "CC-BY-SA"}} }
  let(:mo) { DnzHarvester::MappingOption.new(document, options) }

  describe "#mappings" do
    it "returns the mappings hash" do
      mo.mappings.should eq({"Non commercial" => "CC-BY-NC", "Share" => "CC-BY-SA"})
    end

    it "returns an empty hash when nil" do
      mo.stub(:options) { {mappings: nil} }
      mo.mappings.should eq({})
    end
  end

  describe "#nodes_text" do
    it "returns the text within the nodes" do
      mo.stub(:nodes) { [mock(:node, text: "Dogs")] }
      mo.nodes_text.should eq "Dogs"
    end
  end

  describe "#value" do
    it "returns CC-BY-NC" do
      mo.stub(:nodes_text) { "Non commercial" }
      mo.value.should eq "CC-BY-NC"
    end

    it "returns CC-BY-SA" do
      mo.stub(:nodes_text) { "Share" }
      mo.value.should eq "CC-BY-SA"
    end

    it "returns nil when it doesn't match any expression" do
      mo.stub(:nodes_text) { "Public" }
      mo.value.should be_nil
    end
  end
end