require "spec_helper"

describe HarvesterCore::Modifiers do

  class TestParser < HarvesterCore::Base
  end

  let(:record) { TestParser.new }

  before(:each) do
    record.stub(:original_attributes) { {category: "Images"} }
  end
  
  describe "#get" do
    it "initializes a new AttributeValue with the value from the attribute" do
      record.get(:category).should be_a HarvesterCore::AttributeValue
      record.get(:category).original_value.should eq ["Images"]
    end
  end

  describe "#fetch" do
    context "XML document" do
      let(:document) { Nokogiri::XML::Document.new }
      before { record.stub(:document) { document } }

      it "applies the xpath to the document and returns value object" do
        node = mock(:node, text: "12345")
        document.should_receive(:xpath).with("//dc:identifier") { node }
        value = record.fetch(xpath: "//dc:identifier")
        value.should be_a HarvesterCore::AttributeValue
        value.to_a.should eq ["12345"]
      end

      it "returns an empty value object when document is not present" do
        record.stub(:document) { nil }
        value = record.fetch(xpath: "//dc:identifier")
        value.should be_a HarvesterCore::AttributeValue
        value.to_a.should eq []
      end
    end

    context "JSON document" do
      let(:document) { {"location" => 1234} }
      before { record.stub(:document) { document } }

      it "returns the value object" do
        value = record.fetch(path: "location")
        value.should be_a HarvesterCore::AttributeValue
        value.to_a.should eq [1234]
      end
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