require "spec_helper"

describe DnzHarvester::ConditionalOption do
  
  let(:document) { mock(:document) }
  let(:options) { {xpath: "table/tr", if: {"td[1]" => "dc.identifier.citation"}, value: "td[2]"} }
  let(:co) { DnzHarvester::ConditionalOption.new(document, options) }

  describe "#initialize" do
    it "assigns the document and options" do
      co.document.should eq document
      co.options.should eq options
    end
  end

  describe "#nodes" do
    let(:node) { mock(:node) }

    it "finds the nodes specified by the xpath string" do
      document.should_receive(:xpath).with("//table/tr").and_return([node])
      co.nodes.should eq [node]
    end

    it "returns a empty array when xpath is not defined" do
      co.stub(:options) { {xpath: "", if: {"td[1]" => "dc.citation"}, value: "td[2]"} }
      co.nodes.should eq []
    end
  end

  describe "if_xpath" do
    it "returns the xpath for the condition" do
      co.if_xpath.should eq "td[1]"
    end
  end

  describe "if_value" do
    it "returns the value to be searched for" do
      co.if_value.should eq "dc.identifier.citation"
    end
  end

  describe "#matching_node" do
    let(:container_node) { mock(:node) }

    it "returns the node that matches the conditions" do
      end_node = mock(:node, text: "dc.identifier.citation")
      container_node.should_receive(:xpath).with("td[1]") { end_node }
      co.stub(:nodes) { [container_node] }
      co.matching_node.should eq container_node
    end

    it "returns nil when it doesn't match any node" do
      end_node = mock(:node, text: "dc.language")
      container_node.should_receive(:xpath).with("td[1]") { end_node }
      co.stub(:nodes) { [container_node] }
      co.matching_node.should be_nil
    end
  end

  describe "#value" do
    let(:container_node) { mock(:node) }
    let(:end_node) { mock(:node, text: "Thesis") }

    it "finds the node with the specified xpath and extracts the text" do
      end_node = mock(:node, text: "Thesis")
      container_node.stub(:xpath).with("td[2]") { end_node }
      co.stub(:matching_node) { container_node }
      co.value.should eq "Thesis"
    end
  end
end