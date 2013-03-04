require "spec_helper"

describe HarvesterCore::Modifiers::Joiner do

  let(:klass) { HarvesterCore::Modifiers::Joiner }
  let(:join) { klass.new(["cats", "dogs"], ",") }

  describe "#initialize" do
    it "assigns the original_value and a separator" do
      join.original_value.should eq ["cats","dogs"]
      join.joiner.should eq ","
    end
  end

  describe "value" do
    it "joins the multiple elements into one" do
      join.modify.should eq ["cats,dogs"]
    end
  end
end