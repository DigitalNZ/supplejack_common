require "spec_helper"

describe HarvesterCore::Modifiers::WhitespaceStripper do

  let(:klass) { HarvesterCore::Modifiers::WhitespaceStripper }
  let(:whitespace) { klass.new(" cats ") }

  describe "#initialize" do
    it "assigns the original_value" do
      whitespace.original_value.should eq [" cats "]
    end
  end

  describe "#modify" do
    let(:node) { mock(:node) }

    it "returns a stripped array of values" do
      whitespace.stub(:original_value) { [" Dogs ", " cats "] }
      whitespace.modify.should eq ["Dogs", "cats"]
    end

    it "returns the same array when the elements are not string" do
      whitespace.stub(:original_value) { [ node, node ] }
      whitespace.modify.should eq [node, node]
    end
  end
end