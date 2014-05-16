# The Supplejack code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack_core 

require "spec_helper"

describe HarvesterCore::Modifiers do

  class ModifiersTestParser < HarvesterCore::Base
  end

  let(:record) { ModifiersTestParser.new }

  before(:each) do
    record.stub(:attributes) { {category: "Images"} }
  end
  
  describe "#get" do
    it "initializes a new AttributeValue with the value from the attribute" do
      record.get(:category).should be_a HarvesterCore::AttributeValue
      record.get(:category).original_value.should eq ["Images"]
    end
  end

  describe "#compose" do
    let(:thumb) { HarvesterCore::AttributeValue.new("http://google.com/1") }
    let(:extension) { HarvesterCore::AttributeValue.new("thumb.jpg") }

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