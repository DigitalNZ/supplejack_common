require "spec_helper"

describe DnzHarvester::OptionTransformers::StripWhitespaceOption do

  let(:klass) { DnzHarvester::OptionTransformers::StripWhitespaceOption }
  let(:whitespace) { klass.new(" cats ") }

  describe "#initialize" do
    it "assigns the original_value" do
      whitespace.original_value.should eq [" cats "]
    end
  end

  describe "#value" do
    let(:node) { mock(:node) }

    it "returns a stripped array of values" do
      whitespace.stub(:original_value) { [" Dogs ", " cats "] }
      whitespace.value.should eq ["Dogs", "cats"]
    end

    it "returns the same array when the elements are not string" do
      whitespace.stub(:original_value) { [ node, node ] }
      whitespace.value.should eq [node, node]
    end
  end
end