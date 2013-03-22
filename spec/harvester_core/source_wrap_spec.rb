require "spec_helper"

describe HarvesterCore::SourceWrap do

  let(:source) { mock(:source, attributes: {"title" => "Hi"}) }
  let(:wrap) { HarvesterCore::SourceWrap.new(source) }
  
  describe "#[]" do
    it "should return the specified attribute" do
      wrap[:title].to_a.should eq ["Hi"]
    end

    it "should return a AttributeValue object" do
      wrap[:title].should be_a HarvesterCore::AttributeValue
    end
  end
end