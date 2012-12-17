require "spec_helper"

describe HarvesterCore::OptionTransformers::ParseDateOption do

  let(:klass) { HarvesterCore::OptionTransformers::ParseDateOption }
  let(:parse_date) { klass.new("2012-10-10", true) }
  
  describe "#initialize" do
    it "assigns the original value and optional format" do
      parse_date.original_value.should eq ["2012-10-10"]
      parse_date.format.should be_nil
    end
  end

  describe "#value" do
    it "parses the date with Chronic" do
      parse_date.stub(:original_value) { ["1st of January 1997"] }
      parse_date.value.should eq [Time.utc(1997, 1, 1, 12)]
    end

    it "parses the date with a specific format" do
      parse_date.stub(:original_value) { ["01/12/1997"] }
      parse_date.stub(:format) { "%d/%m/%Y" }
      parse_date.value.should eq [Time.utc(1997, 12, 1)]
    end

    it "parses a circa date" do
      parse_date.stub(:original_value) { ["circa 1994"] }
      parse_date.value.should eq [Time.utc(1994, 1, 1, 12)]
    end

    it "parses a decade date (1940s)" do
      parse_date.stub(:original_value) { ["1940s"] }
      parse_date.value.should eq [Time.utc(1940, 1, 1, 12)]
    end

    # it "returns a new time object when is a time array" do
    #   parse_date.stub(:original_value) { [0, 52, 3, 5, 12, 2012, 3, 340, false, "UTC"] }
    #   parse_date.value.should eq [Time.new()]
    # end
  end

  describe "#normalized" do
    it "converts a circa year into a date" do
      parse_date.normalized("circa 1994").should eq "1994/1/1"
    end

    it "converts a decade date into a date" do
      parse_date.normalized("1994s").should eq "1994/1/1"
    end

    it "converts a year into a date" do
      parse_date.normalized("1994").should eq "1994/1/1"
    end
  end

  # describe "time_array?" do
  #   it "returns true" do
  #     parse_date.time_array?([0, 52, 3, 5, 12, 2012, 3, 340, false, "UTC"]).should be_true
  #   end

  #   it "returns false" do
  #     parse_date.time_array?(["01/12/1997"]).should be_false
  #   end
  # end
end