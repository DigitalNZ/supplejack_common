

require "spec_helper"

describe SupplejackCommon::Modifiers::WhitespaceCompactor do

  let(:klass) { SupplejackCommon::Modifiers::WhitespaceCompactor }
  let(:whitespace) { klass.new(["cats", "bats"]) }

  describe "#initialize" do
    it "assigns the original_value" do
      whitespace.original_value.should eq ["cats", "bats"]
    end
  end

  describe "#modify" do
    let(:node) { mock(:node) }

    it "returns a compacted array of values" do
      whitespace.stub(:original_value) { ["Dogs   Hotels  - foo", "Job   blah"] }
      whitespace.modify.should eq ["Dogs Hotels - foo", "Job blah"]
    end

    it "returns the same array when the elements are not string" do
      whitespace.stub(:original_value) { [ node, node ] }
      whitespace.modify.should eq [node, node]
    end
  end
end