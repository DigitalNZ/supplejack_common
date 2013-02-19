require "spec_helper"

describe HarvesterCore::OptionTransformers::SplitOption do

  let(:klass) { HarvesterCore::OptionTransformers::SplitOption }
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

    it "splits based on a regular expression" do
      split = klass.new("Dogs, cats and elephants", /,|and/)
      split.value.should eq ["Dogs", " cats ", " elephants"]
    end
  end
end