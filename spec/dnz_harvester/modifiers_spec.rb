require "spec_helper"

describe DnzHarvester::Modifiers do

  class TestParser < DnzHarvester::Base
  end

  let(:record) { TestParser.new }

  before(:each) do
    record.stub(:original_attributes) { {category: "Images"} }
  end
  
  describe "#get" do
    it "initializes a new AttributeValue with the value from the attribute" do
      record.get(:category).should be_a DnzHarvester::AttributeValue
      record.get(:category).original_value.should eq ["Images"]
    end
  end

  describe "#fetch" do
    
  end

  describe "#compose" do
    
  end
end