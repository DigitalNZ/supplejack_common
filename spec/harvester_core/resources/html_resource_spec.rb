require "spec_helper"

describe HarvesterCore::HtmlResource do

  let(:klass) { HarvesterCore::HtmlResource }
  let(:resource) { klass.new("http://google.com/1", {}) }
  
  describe "#document" do
    it "should parse the resource as HTML" do
      resource.stub(:fetch_document) { "</html>" }
      resource.document.should be_a Nokogiri::HTML::Document
    end
  end
end