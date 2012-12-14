require "spec_helper"

describe DnzHarvester::OptionTransformers::SplitOption do

  let(:klass) { DnzHarvester::OptionTransformers::SplitOption }
  let(:split) { klass.new("Dogs, cats", ",") }

  describe "#initialize" do
    it "assigns the original_value and a separator" do
      split.original_value.should eq ["Dogs, cats"]
      split.separator.should eq ","
    end
  end

  describe "value" do
    it "splits the string into a array" do
      split.value.should eq ["Dogs", " cats"]
    end

    it "splits an array of strings" do
      split.stub(:original_value) { ["Dogs,cats", "fish,tiger"] }
      split.value.should eq ["Dogs", "cats", "fish", "tiger"]
    end
  end
end