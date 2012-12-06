require "spec_helper"

describe DnzHarvester::Xml::Base do
  
  let(:klass) { DnzHarvester::Xml::Base }
  let(:document) { mock(:document) }

  after do
    klass._base_urls[klass.identifier] = []
    klass._attribute_definitions[klass.identifier] = {}
  end

  describe ".record_url_xpath" do
    it "stores the xpath to retrieve every record url" do
      klass.record_url_xpath "loc"
      klass._record_url_xpath.should eq "loc"
    end
  end

  describe ".index_document" do
    before do
      klass.base_url "http://google.com"
    end

    it "creates a nokogiri document with the list of record urls" do
      RestClient.stub(:get).with("http://google.com") { "Some xml" }
      Nokogiri.should_receive(:parse).with("Some xml") { document }
      klass.index_document.should eq document
    end
  end

  describe ".records" do
    let(:xml) { File.read("spec/dnz_harvester/integrations/source_data/xml_parser_urls.xml") }

    before do
      klass.record_url_xpath "//loc"
      klass.stub(:index_document) { Nokogiri.parse(xml) }
    end

    it "initializes a record for every url" do
      klass.should_receive(:new).once.with("http://www.nzonscreen.com/api/title/weekly-review-no-395-1949")
      klass.records
    end

    it "limits the number of records to 1" do
      node = mock(:node, text: "http://google.com")
      klass.stub(:index_document) { mock(:doc, xpath: [node, node, node]) }
      klass.records(limit: 1).size.should eq 1
    end
  end

  describe "#url" do
    before do
      klass.any_instance.stub(:set_attribute_values) { nil }
    end

    let(:record) { klass.new("http://google.com") }

    it "returns the url" do
      record.url.should eq "http://google.com"
    end

    it "returns the url with basic auth values" do
      klass.basic_auth "username", "password"
      record.url.should eq "http://username:password@google.com"
    end
  end

  describe "#document" do
    before do
      klass.any_instance.stub(:set_attribute_values) { nil }
    end

    let(:document) { mock(:document) }
    let(:record) { klass.new("http://google.com") }

    it "parses the record xml" do
      DnzHarvester::Utils.stub(:get) { "Some xml data" }
      Nokogiri.should_receive(:parse).with("Some xml data") { document }
      record.document
    end
  end
end