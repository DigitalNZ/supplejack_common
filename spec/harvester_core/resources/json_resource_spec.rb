require "spec_helper"

describe HarvesterCore::JsonResource do

  let(:klass) { HarvesterCore::JsonResource }
  let(:resource) { klass.new("http://google.com/1", {}) }
  
  describe "#document" do
    it "should parse the resource as JSON" do
      resource.stub(:fetch_document) { {title: "Value"}.to_json }
      resource.document.should eq({"title" => "Value"})
    end
  end

  describe '#fetch' do
    it 'returns the value object' do
    	resource.stub(:fetch_document) { {title: 'Lorem'}.to_json }
    	value = resource.fetch('title')
      value.should be_a HarvesterCore::AttributeValue
      value.to_a.should eq ['Lorem']
    end
  end
end