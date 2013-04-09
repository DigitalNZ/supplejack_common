require "spec_helper"

describe HarvesterCore::XmlResource do

  let(:klass) { HarvesterCore::XmlResource }
  let(:resource) { klass.new("http://google.com/1", {}) }
  
  describe "#document" do
    it "should parse the resource as XML" do
      resource.stub(:fetch_document) { "</xml>" }
      resource.document.should be_a Nokogiri::XML::Document
    end
  end
end