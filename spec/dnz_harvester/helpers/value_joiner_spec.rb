require "spec_helper"

describe DnzHarvester::ValueJoiner do

  let(:klass) { DnzHarvester::ValueJoiner }
  let(:joiner) { klass.new(["Dogs ", "cats"], ",") }

  describe "#initialize" do
    it "assigns the original_value and a joiner" do
      joiner.original_value.should eq ["Dogs ", "cats"]
      joiner.joiner.should eq ","
    end
  end

  describe "#standarized_value" do
    it "returns the same array" do
      joiner.standarized_value.should eq ["Dogs", "cats"]
    end

    it "splits the string by the joiner" do
      joiner.stub(:original_value) { "Dogs, cats" }
      joiner.standarized_value.should eq ["Dogs", "cats"]
    end
  end

  describe "#value" do
    it "returns a array of values" do
      joiner.value.should eq "Dogs,cats"
    end
  end
end