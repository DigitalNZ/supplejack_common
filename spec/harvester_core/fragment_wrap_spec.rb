# The Supplejack code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack_core 

require "spec_helper"

describe HarvesterCore::FragmentWrap do

  let(:fragment) { mock(:fragment, attributes: {"title" => "Hi"}) }
  let(:wrap) { HarvesterCore::FragmentWrap.new(fragment) }
  
  describe "#[]" do
    it "should return the specified attribute" do
      wrap[:title].to_a.should eq ["Hi"]
    end

    it "should return a AttributeValue object" do
      wrap[:title].should be_a HarvesterCore::AttributeValue
    end
  end
end