require "spec_helper"

describe DnzHarvester::Modifiers::RangeSelector do
  
  let(:klass) { DnzHarvester::Modifiers::RangeSelector }

  describe "#initialize" do
    it "assigns the original value and range options" do
      selector = klass.new("Value", :first, :last)
      selector.original_value.should eq "Value"
      selector.instance_variable_get("@start_range").should eq :first
      selector.instance_variable_get("@end_range").should eq :last
    end
  end

  describe "#start_range" do
    it "returns 0" do
      klass.new("Value", :first).start_range.should eq 0
    end

    it "returns -1" do
      klass.new("Value", :last).start_range.should eq -1
    end

    it "returns 4" do
      klass.new("Value", 5).start_range.should eq 4
    end
  end

  describe "#end_range" do
    it "returns -1" do
      klass.new("Value", :first, :last).end_range.should eq -1
    end

    it "returns 4" do
      klass.new("Value", 1, 5).end_range.should eq 4
    end
  end

  describe "#modify" do
    let(:value) { ["1", "2", "3", "4"] }

    it "returns the first element" do
      klass.new(value, :first).modify.should eq ["1"]
    end

    it "returns the last element" do
      klass.new(value, :last).modify.should eq ["4"]
    end

    it "returns the first 3 elements " do
      klass.new(value, :first, 3).modify.should eq ["1", "2", "3"]
    end
  end
end