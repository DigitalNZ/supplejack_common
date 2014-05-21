# The Supplejack Common code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack_core 

require "spec_helper"

describe ActiveModel::Validations::FormatValidator do
  
  context "validates all values have the correct format" do
    class TestJsonWith < SupplejackCommon::Json::Base
      attribute :dc_type, path: "dc_type"
      validates :dc_type, format: {with: /Images|Videos/}
    end

    it "should be valid" do
      record = TestJsonWith.new({"dc_type" => ["Videos", "Images"]})
      record.set_attribute_values
      record.valid?.should be_true
    end

    it "should not be valid when at least one value doesn't match " do
      record = TestJsonWith.new({"dc_type" => ["Videos", "Photos"]})
      record.set_attribute_values
      record.valid?.should be_false
    end
  end

  context "validates all values don't match the regexp" do
    class TestJsonWithout < SupplejackCommon::Json::Base
      attribute :dc_type, path: "dc_type"
      validates :dc_type, format: {without: /Images|Videos/}
    end

    it "should be valid" do
      record = TestJsonWithout.new({"dc_type" => ["Photos", "Manuscripts"]})
      record.set_attribute_values
      record.valid?.should be_true
    end

    it "should not be valid when at least one value matches the without regexp" do
      record = TestJsonWithout.new({"dc_type" => ["Videos", "Photos"]})
      record.set_attribute_values
      record.valid?.should be_false
    end
  end
end
