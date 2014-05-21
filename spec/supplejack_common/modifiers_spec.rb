# The Supplejack Common code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack 

require "spec_helper"

describe SupplejackCommon::Modifiers do

  class ModifiersTestParser < SupplejackCommon::Base
  end

  let(:record) { ModifiersTestParser.new }

  before(:each) do
    record.stub(:attributes) { {category: "Images"} }
  end
  
  describe "#get" do
    it "initializes a new AttributeValue with the value from the attribute" do
      record.get(:category).should be_a SupplejackCommon::AttributeValue
      record.get(:category).original_value.should eq ["Images"]
    end
  end

  describe "#compose" do
    let(:thumb) { SupplejackCommon::AttributeValue.new("http://google.com/1") }
    let(:extension) { SupplejackCommon::AttributeValue.new("thumb.jpg") }

    it "joins multiple attribute values and a string" do
      value = record.compose(thumb, "/", extension)
      value.to_a.should eq ["http://google.com/1/thumb.jpg"]
    end

    it "joins the values with a comma" do
      value = record.compose("dogs", "cats", extension, {separator: ", "})
      value.to_a.should eq ["dogs, cats, thumb.jpg"]
    end
  end
end