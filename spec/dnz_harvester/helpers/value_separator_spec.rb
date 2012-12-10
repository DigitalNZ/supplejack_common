require "spec_helper"

describe DnzHarvester::ValueSeparator do

  let(:klass) { DnzHarvester::ValueSeparator }
  let(:separator) { klass.new("Dogs, cats", ",") }

  describe "#initialize" do
    it "assigns the original_value and a separator" do
      separator.original_value.should eq "Dogs, cats"
      separator.separator.should eq ","
    end
  end

  describe "#standarized_value" do
    it "returns the same string value" do
      separator.standarized_value.should eq "Dogs, cats"
    end

    it "converts an array in to a string" do
      separator.stub(:original_value) { ["Dogs", "cats"] }
      separator.standarized_value.should eq "Dogs,cats"
    end
  end

  describe "#value" do
    it "returns a array of values" do
      separator.value.should eq ["Dogs", "cats"]
    end
  end
end