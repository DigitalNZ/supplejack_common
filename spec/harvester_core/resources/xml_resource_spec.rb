require "spec_helper"

describe HarvesterCore::XmlResource do

  let(:klass) { HarvesterCore::XmlResource }
  let(:resource) { klass.new("http://google.com/1", {namespaces: { dc: "http://purl.org/dc/elements/1.1/" } }) }

  describe "#initialize" do
    it "should set the namespaces class attribute" do
      resource.class._namespaces[:dc].should eq "http://purl.org/dc/elements/1.1/"
    end
  end
  
  describe "#document" do
    it "should parse the resource as XML" do
      resource.stub(:fetch_document) { "</xml>" }
      resource.document.should be_a Nokogiri::XML::Document
    end
  end

  describe "#strategy_value" do
    let(:doc) { double(:document) }

    it "should create a new XpathOption with the namespaces class attribute" do
      resource.stub(:document) { doc }
      HarvesterCore::XpathOption.should_receive(:new).with(doc, {xpath: '/doc'}, dc: "http://purl.org/dc/elements/1.1/" ) { double(:option).as_null_object }
      resource.strategy_value({xpath: '/doc'})
    end
  end
end