require "spec_helper"

describe DnzHarvester::Filters::RangeSelector do
  
  let(:klass) { DnzHarvester::Filters::RangeSelector }
  let(:record) { mock(:record) }

  describe "#initialize" do
    it "assigns the record and range options" do
      selector = klass.new(record, :first, :last)
      selector.record.should eq record
      selector.instance_variable_get("@start_range").should eq :first
      selector.instance_variable_get("@end_range").should eq :last
    end
  end

  describe "#start_range" do
    it "returns 0" do
      klass.new(record, :first).start_range.should eq 0
    end

    it "returns -1" do
      klass.new(record, :last).start_range.should eq -1
    end

    it "returns 4" do
      klass.new(record, 5).start_range.should eq 4
    end
  end

  describe "#end_range" do
    it "returns -1" do
      klass.new(record, :first, :last).end_range.should eq -1
    end

    it "returns 4" do
      klass.new(record, 1, 5).end_range.should eq 4
    end
  end

  describe "#within" do
    before do
      record.stub(:original_attributes) { {category: ["Images", "Newspapers"], dc_type: ["1", "2", "3", "4"]} }
    end

    it "returns the first element of category" do
      klass.new(record, :first).within(:category).should eq "Images"
    end

    it "returns the last element of category" do
      klass.new(record, :last).within(:category).should eq "Newspapers"
    end

    it "returns the first 3 elements of dc_type " do
      klass.new(record, :first, 3).within(:dc_type).should eq ["1", "2", "3"]
    end
  end
end