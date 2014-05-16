# The Supplejack code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack_core 

require "spec_helper"

describe HarvesterCore::Modifiers::DateParser do

  let(:klass) { HarvesterCore::Modifiers::DateParser }
  let(:parse_date) { klass.new("2012-10-10", true) }
  
  describe "#initialize" do
    it "assigns the original value and optional format" do
      parse_date.original_value.should eq ["2012-10-10"]
      parse_date.format.should be_nil
    end
  end

  describe "#modify" do
    it "parses the date with Chronic" do
      parse_date.stub(:original_value) { ["1st of January 1997"] }
      parse_date.modify.should eq [Time.utc(1997, 1, 1, 12)]
    end

    it "parses the date with a specific format" do
      parse_date.stub(:original_value) { ["01/12/1997"] }
      parse_date.stub(:format) { "%d/%m/%Y" }
      parse_date.modify.should eq [Time.utc(1997, 12, 1)]
    end

    it "parses a circa date" do
      parse_date.stub(:original_value) { ["circa 1994"] }
      parse_date.modify.should eq [Time.utc(1994, 1, 1, 12)]
    end

    it "parses a decade date (1940s)" do
      parse_date.stub(:original_value) { ["1940s"] }
      parse_date.modify.should eq [Time.utc(1940, 1, 1, 12)]
    end
  end

  describe "#parse_date" do
    it "rescues from from a Chronic exception" do
      Chronic.stub(:parse).and_raise(StandardError.new("ArgumentError - invalid date"))
      parse_date.parse_date("2009/1/1")
      parse_date.errors.should eq ["Cannot parse date: '2009/1/1', ArgumentError - invalid date"]
    end

    it "rescues from a DateTime exception" do
      parse_date.stub(:format) { "%d %m %Y" }
      DateTime.stub(:strptime).and_raise(StandardError.new("ArgumentError - invalid date"))
      parse_date.parse_date("2009/1/1")
      parse_date.errors.should eq ["Cannot parse date: '2009/1/1', ArgumentError - invalid date"]
    end

    it "returns the same time object" do
      time = Time.now
      parse_date.parse_date(time).should eq time
    end

    it "parsers a standard time with time zone" do
      time = Time.parse("Fri, 21 Dec 2012 12:12:00 +1300")
      parse_date.parse_date("Fri, 21 Dec 2012 12:12:00 +1300").should eq time
    end
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
end