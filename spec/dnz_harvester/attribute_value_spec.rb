require "spec_helper"

describe DnzHarvester::AttributeValue do

  let(:klass) { DnzHarvester::AttributeValue }

  let(:value) { klass.new("Images") }

  describe "#initialize" do
    it "assigns the original_value and turns it into an array" do
      value = klass.new("Images")
      value.original_value.should eq ["Images"]
    end

    it "removes empty strings" do
      value = klass.new("")
      value.original_value.should eq []
    end
  end

  describe "present?" do
    it "returns true when it has any value" do
      value.stub(:original_value) { ["Images"] }
      value.present?.should be_true
    end

    it "returns false when it doesn't have any value" do
      value.stub(:original_value) { [] }
      value.present?.should be_false
    end
  end
  
end