require "spec_helper"

describe HarvesterCore::OptionTransformers::JoinOption do

  let(:klass) { HarvesterCore::OptionTransformers::JoinOption }
  let(:join) { klass.new(["cats", "dogs"], ",") }

  describe "#initialize" do
    it "assigns the original_value and a separator" do
      join.original_value.should eq ["cats","dogs"]
      join.joiner.should eq ","
    end
  end

  describe "value" do
    it "joins the multiple elements into one" do
      join.value.should eq ["cats,dogs"]
    end
  end
end