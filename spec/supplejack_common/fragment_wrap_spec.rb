

require "spec_helper"

describe SupplejackCommon::FragmentWrap do

  let(:fragment) { mock(:fragment, attributes: {"title" => "Hi"}) }
  let(:wrap) { SupplejackCommon::FragmentWrap.new(fragment) }
  
  describe "#[]" do
    it "should return the specified attribute" do
      wrap[:title].to_a.should eq ["Hi"]
    end

    it "should return a AttributeValue object" do
      wrap[:title].should be_a SupplejackCommon::AttributeValue
    end
  end
end