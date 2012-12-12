require "spec_helper"

describe DnzHarvester::DateParser do

  let(:klass) { DnzHarvester::DateParser }
  let(:date_parse) { klass.new("2012-10-10", true) }
  
  describe "#initialize" do
    it "assigns the original value and optional format" do
      date_parse.original_value.should eq "2012-10-10"
      date_parse.format.should be_nil
    end
  end

  describe "#value" do
    it "parses the date with Chronic" do
      date_parse.stub(:original_value) { "1st of January 1997" }
      date_parse.value.should eq Time.utc(1997, 1, 1, 12)
    end

    it "parses the date with a specific format" do
      date_parse.stub(:original_value) { "01/12/1997" }
      date_parse.stub(:format) { "%d/%m/%Y" }
      date_parse.value.should eq Time.utc(1997, 12, 1)
    end

    it "parses a circa date" do
      date_parse.stub(:original_value) { "circa 1994" }
      date_parse.value.should eq Time.utc(1994, 1, 1, 12)
    end

    it "parses a decade date (1940s)" do
      date_parse.stub(:original_value) { "1940s" }
      date_parse.value.should eq Time.utc(1940, 1, 1, 12)
    end
  end

  describe "#normalized" do
    it "converts a circa year into a date" do
      date_parse.stub(:original_value) { "circa 1994" }
      date_parse.normalized.should eq "1994/1/1"
    end

    it "converts a decade date into a date" do
      date_parse.stub(:original_value) { "1994s" }
      date_parse.normalized.should eq "1994/1/1"
    end

    it "converts a year into a date" do
      date_parse.stub(:original_value) { "1994" }
      date_parse.normalized.should eq "1994/1/1"
    end
  end
end