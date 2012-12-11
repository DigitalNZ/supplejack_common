require "spec_helper"

describe DnzHarvester::WhitespaceStripper do

  let(:klass) { DnzHarvester::WhitespaceStripper }
  let(:stripper) { klass.new(" cats ") }

  describe "#initialize" do
    it "assigns the original_value" do
      stripper.original_value.should eq " cats "
    end
  end

  describe "#value" do
    let(:node) { mock(:node) }

    it "returns a stripped array of values" do
      stripper.stub(:original_value) { [" Dogs ", " cats "] }
      stripper.value.should eq ["Dogs", "cats"]
    end

    it "returns the same array when the elements are not string" do
      stripper.stub(:original_value) { [ node, node ] }
      stripper.value.should eq [node, node]
    end

    it "returns a stripped string" do
      stripper.value.should eq "cats"
    end

    it "returns the same object if is not a string" do
      stripper.stub(:original_value) { node }
      stripper.value.should eq node
    end
  end
end