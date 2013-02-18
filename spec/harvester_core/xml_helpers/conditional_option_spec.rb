require "spec_helper"

describe HarvesterCore::ConditionalOption do
  
  let(:document) { mock(:document) }
  let(:options) { {xpath: "table/tr", if: {"td[1]" => "dc.identifier.citation"}, value: "td[2]"} }
  let(:co) { HarvesterCore::ConditionalOption.new(document, options) }

  describe "if_xpath" do
    it "returns the xpath for the condition" do
      co.if_xpath.should eq "td[1]"
    end
  end

  describe "if_values" do
    it "returns the value to be searched for" do
      co.if_values.should eq ["dc.identifier.citation"]
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

    it "returns nil when there is no matching_node" do
      co.stub(:matching_node) { nil }
      co.value.should be_nil
    end
  end
end