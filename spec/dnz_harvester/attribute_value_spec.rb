require "spec_helper"

describe DnzHarvester::AttributeValue do

  let(:klass) { DnzHarvester::AttributeValue }

  describe "#initialize" do
    it "assigns the original_value and turns it into an array" do
      value = klass.new("Images")
      value.original_value.should eq ["Images"]
    end
  end
  
end