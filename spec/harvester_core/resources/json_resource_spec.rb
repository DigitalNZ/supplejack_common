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
end