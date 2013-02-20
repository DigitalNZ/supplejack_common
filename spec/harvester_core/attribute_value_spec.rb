require "spec_helper"

describe HarvesterCore::AttributeValue do

  let(:klass) { HarvesterCore::AttributeValue }

  let(:value) { klass.new("Images") }

  describe "#initialize" do
    it "assigns the original_value and turns it into an array" do
      value = klass.new("Images")
      value.original_value.should eq ["Images"]
    end

    it "removes empty strings" do
      value = klass.new("")
      value.original_value.should eq []
    end
  end

  describe "present?" do
    it "returns true when it has any value" do
      value.stub(:original_value) { ["Images"] }
      value.present?.should be_true
    end

    it "returns false when it doesn't have any value" do
      value.stub(:original_value) { [] }
      value.present?.should be_false
    end
  end

  describe "#+" do
    it "adds the values of two AttributeValue objects" do
      value1 = klass.new("Images")
      value2 = klass.new(["Videos", "News"])
      value3 = value1 + value2
      value3.original_value.should eq ["Images", "Videos", "News"]
    end

    it "adds the values of a array to a attribute value" do
      value1 = klass.new("Images")
      value2 = value1 + ["Videos"]
      value2.original_value.should eq ["Images", "Videos"]
    end

    it "adds a string to a attribute value" do
      value1 = klass.new("Images")
      value2 = value1 + "Videos"
      value2.original_value.should eq ["Images", "Videos"]
    end
  end

  describe "#includes?" do
    context "string matching" do
      let(:value) { klass.new("Images") }

      it "returns true" do
        value.includes?("Images").should be_true
        value.include?("Images").should be_true
      end

      it "returns false" do
        value.includes?("Videos").should be_false
      end
    end

    context "regexp matching" do
      let(:value) { klass.new("Foxes and cats") }

      it "returns true" do
        value.includes?(/Fox/).should be_true
      end

      it "returns false" do
        value.includes?(/Tiger/).should be_false
      end
    end
  end
  
end