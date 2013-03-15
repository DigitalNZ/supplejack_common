require "spec_helper"

describe HarvesterCore::Enrichment do

  let(:klass) { HarvesterCore::Enrichment }
  let(:block) { Proc.new {} }
  let(:record) { mock(:record, attributes: {}) }
  let(:enrichment) { klass.new(:ndha_rights, block, record) }
  
  describe "#initialize" do
    it "sets the name and block" do
      enrichment.name.should eq :ndha_rights
      enrichment.block.should eq block
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
      enrichment = klass.new(:rights, Proc.new { url "http://google.com" }, record)
      enrichment._url.should eq "http://google.com"
    end

    it "should evaluate the get and then the URL" do
      enrichment = klass.new(:rights, Proc.new { url "http://google.com/#{record.dc_identifier}" }, mock(:record, dc_identifier: "1.jpg"))
      enrichment._url.should eq "http://google.com/1.jpg"
    end
  end

  describe "#resource" do
    let!(:enrichment) { klass.new(:ndha_rights, Proc.new { url "http://goo.gle/1"; format "xml" }, record) }

    before do
      record.stub(:class) { mock(:class, :_throttle => {}) }
    end

    it "should initialize a xml resource object" do
      HarvesterCore::XmlResource.should_receive(:new).with("http://goo.gle/1", {})
      enrichment.resource
    end

    it "should initialize a json resource object" do
      enrichment = klass.new(:ndha_rights, Proc.new { url "http://goo.gle/1"; format "json" }, record)
      HarvesterCore::JsonResource.should_receive(:new).with("http://goo.gle/1", {})
      enrichment.resource
    end

    it "should initialize a file resource object" do
      enrichment = klass.new(:ndha_rights, Proc.new { url "http://goo.gle/1"; format "file" }, record)
      HarvesterCore::FileResource.should_receive(:new).with("http://goo.gle/1", {})
      enrichment.resource
    end

    it "should return a resource object" do
      enrichment.resource.should be_a HarvesterCore::Resource
    end

    it "initializes the resource with throttle options" do
      record.stub(:class) { mock(:class, :_throttle => {host: "gdata.youtube.com", delay: 1}) }
      HarvesterCore::Resource.should_receive(:new).with("http://goo.gle/1", {throttling_options: {host: "gdata.youtube.com", delay: 1}})
      enrichment.resource
    end
  end

  # describe "#set_attribute_values" do
  #   let!(:enrichment) { klass.new(:ndha_rights, Proc.new { url "http://goo.gle/1"; attribute :dc_rights, xpath: "//dc:rights" }, record) }

  #   it "should initialize a attribute builder" do
  #     HarvesterCore::AttributeBuilder.should_receive(:new).with(enrichment, )
  #   end
  # end
end