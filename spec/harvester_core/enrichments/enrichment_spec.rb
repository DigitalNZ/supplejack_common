require "spec_helper"

describe HarvesterCore::Enrichment do

  class TestParser; 
    def self._throttle; nil; end
  end

  let(:klass) { HarvesterCore::Enrichment }
  let(:block) { Proc.new {} }
  let(:record) { mock(:record, attributes: {}) }
  let(:enrichment) { klass.new(:ndha_rights, {block: block}, record, TestParser) }
  
  describe "#initialize" do
    it "sets the name and block" do
      enrichment.name.should eq :ndha_rights
      enrichment.block.should eq block
    end

    it "sets the parser class" do
      enrichment.parser_class.should eq TestParser
    end
  end

  describe "#url" do
    it "should store the enrichment URL" do
      enrichment.url "http://google.com"
      enrichment._url.should eq "http://google.com"
    end
  end

  describe "#format" do
    it "should store the enrichment format" do
      enrichment.format :xml
      enrichment._format.should eq :xml
    end
  end

  describe "#requires" do
    it "should store a requirement with a name and block" do
      enrichment.requires :thumbnail_url do
        "Hi"
      end

      enrichment._required_attributes.should include(thumbnail_url: "Hi")
    end

    it "rescues from any exception in the block" do
      enrichment.requires :thumbnail_url do
        raise StandardError.new("Error!!")
      end

      enrichment._required_attributes.should include(thumbnail_url: nil)
    end
  end

  describe "#namespaces" do
    it "stores the namespaces for the resource" do
      enrichment.namespaces dc: "http://purl.org/dc/elements/1.1/", xsi: "http://www.w3.org/2001/XMLSchema-instance"
      enrichment._namespaces.should eq({dc: "http://purl.org/dc/elements/1.1/", xsi: "http://www.w3.org/2001/XMLSchema-instance"})
    end
  end

  describe "#attribute" do
    it "stores the attribute definitions" do
      enrichment.attribute :dc_rights, xpath: "//dc:identifier"
      enrichment._attribute_definitions.should include(dc_rights: {xpath: "//dc:identifier"})
    end
  end

  describe "#evaluate_block" do
    it "should evaluate the block" do
      enrichment = klass.new(:rights, {block: Proc.new { url "http://google.com" }}, record, TestParser)
      enrichment._url.should eq "http://google.com"
    end

    it "should evaluate the get and then the URL" do
      enrichment = klass.new(:rights, {block: Proc.new { url "http://google.com/#{record.dc_identifier}" }}, mock(:record, dc_identifier: "1.jpg"), TestParser)
      enrichment._url.should eq "http://google.com/1.jpg"
    end
  end

  describe "#resource" do
    let!(:enrichment) { klass.new(:ndha_rights, {block: Proc.new { url "http://goo.gle/1"; format "xml" }}, record, TestParser) }

    before do
      record.stub(:class) { mock(:class, :_throttle => {}) }
    end

    it "should initialize a xml resource object" do
      HarvesterCore::XmlResource.should_receive(:new).with("http://goo.gle/1", {})
      enrichment.resource
    end

    it "should initialize a json resource object" do
      enrichment = klass.new(:ndha_rights, {block: Proc.new { url "http://goo.gle/1"; format "json" }}, record, TestParser)
      HarvesterCore::JsonResource.should_receive(:new).with("http://goo.gle/1", {})
      enrichment.resource
    end

    it "should initialize a file resource object" do
      enrichment = klass.new(:ndha_rights, {block: Proc.new { url "http://goo.gle/1"; format "file" }}, record, TestParser)
      HarvesterCore::FileResource.should_receive(:new).with("http://goo.gle/1", {})
      enrichment.resource
    end

    it "should return a resource object" do
      enrichment.resource.should be_a HarvesterCore::Resource
    end

    it "initializes the resource with throttle options" do
      TestParser.stub(:_throttle) { {host: "gdata.youtube.com", delay: 1} }
      HarvesterCore::Resource.should_receive(:new).with("http://goo.gle/1", {throttling_options: {host: "gdata.youtube.com", delay: 1}})
      enrichment.resource
    end
  end

  describe "#primary" do
    let(:source) { mock(:source).as_null_object }

    before do
      record.stub_chain(:sources, :where).with(priority: 0) { [source] }
    end

    it "returns a wrapped source" do
      enrichment.primary.source.should eq source
    end

    it "should initialize a SourceWrap object" do
      enrichment.primary.should be_a HarvesterCore::SourceWrap
    end
  end

  describe "#enrichable?" do
    it "returns true when all required fields are present" do
      enrichment._required_attributes = {thumbnail_url: "http://google.com/1", title: "Hi"}
      enrichment.enrichable?.should be_true
    end

    it "returns false when a required field is not present" do
      enrichment._required_attributes = {thumbnail_url: nil, title: "Hi"}
      enrichment.enrichable?.should be_false
    end
  end

  describe "#requirements" do
    it "returns the value of the requirement block" do
      enrichment.requires :tap_id do
        12345
      end

      enrichment.requirements[:tap_id].should eq 12345
    end
  end

  describe "#set_attribute_values" do
    # let!(:enrichment) { klass.new(:ndha_rights, Proc.new { url "http://goo.gle/1"; attribute :dc_rights, xpath: "//dc:rights" }, record) }

    it "should add the source_id to the enrichment attributes" do
      enrichment.set_attribute_values
      enrichment.attributes.should include(source_id: "ndha_rights")
    end
  end
end