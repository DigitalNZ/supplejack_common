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