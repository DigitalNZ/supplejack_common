require "spec_helper"

describe DnzHarvester::ValueTruncator do

  let(:string) { "Some description that should be longer than 50 characters" }
  let(:klass) { DnzHarvester::ValueTruncator }
  let(:truncator) { klass.new(string, 50) }

  describe "#initialize" do
    it "assigns the original_value and length" do
      truncator.original_value.should eq string
      truncator.length.should eq 50
    end
  end

  describe "#value" do
    it "truncates the string to 50 characters" do
      truncator.value.should eq "Some description that should be longer than 50 cha"
    end
  end
end