require "spec_helper"

describe DnzHarvester::Filters::AttributeValues do

  let(:record) { mock(:record, original_attributes: {category: "Images"}) }
  
  class TestValues
    include DnzHarvester::Filters::AttributeValues
    attr_reader :record
    def initialize(record)
      @record = record      
    end
  end

  describe "#contents" do
    let(:test_values) { TestValues.new(record) }

    it "returns an array of values" do
      test_values.contents(:category).should eq ["Images"]
    end

    it "returns an empty array" do
      record.stub(:original_attributes) { {category: nil} }
      test_values.contents(:category).should eq []
    end
  end
end