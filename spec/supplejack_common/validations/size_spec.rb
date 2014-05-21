# The Supplejack Common code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack 

require "spec_helper"

describe ActiveModel::Validations::SizeValidator do
  
  context "validates that the attribute has a maximum number of values" do
    class TestJsonSize < SupplejackCommon::Json::Base
      attribute :landing_url, path: "landing_url"
      validates :landing_url, size: { maximum: 2 }
    end

    it "should be valid when it has one value" do
      record = TestJsonSize.new({"landing_url" => ["http://google.com/1"]})
      record.set_attribute_values
      record.valid?.should be_true
    end

    it "should not be valid when it has more than the maximum" do
      record = TestJsonSize.new({"landing_url" => ["http://google.com/1", "http://google.com/2", "http://google.com/3"]})
      record.set_attribute_values
      record.valid?.should be_false
    end
  end

  context "validates that the attribute has the exact number of values" do
    class TestJsonSize < SupplejackCommon::Json::Base
      attribute :landing_url, path: "landing_url"
      validates :landing_url, size: { is: 1 }
    end

    it "should be valid when it has one value" do
      record = TestJsonSize.new({"landing_url" => ["http://google.com/1"]})
      record.set_attribute_values
      record.valid?.should be_true
    end

    it "should not be valid when it has 0 values" do
      record = TestJsonSize.new({"landing_url" => []})
      record.set_attribute_values
      record.valid?.should be_false
    end

    it "should not be valid when it has 2 values" do
      record = TestJsonSize.new({"landing_url" => ["http://google.com/1", "http://google.com/2"]})
      record.set_attribute_values
      record.valid?.should be_false
    end
  end

end
