require "spec_helper"

describe HarvesterCore::Xml::Base do
  
  let(:klass) { HarvesterCore::Xml::Base }
  let(:document) { mock(:document) }

  after do
    klass._base_urls[klass.identifier] = []
    klass._attribute_definitions[klass.identifier] = {}
  end

  describe ".record_url_selector" do
    it "stores the xpath to retrieve every record url" do
      klass.record_url_selector "loc"
      klass._record_url_selector.should eq "loc"
    end
  end

  describe ".record_selector" do
    it "stores the xpath to retrieve every record" do
      klass.record_selector "//items/item"
      klass._record_selector.should eq "//items/item"
    end
  end

  describe ".sitemap?" do
    it "returns true" do
      klass._record_selector = nil
      klass._record_url_selector = "//loc"
      klass.sitemap?.should be_true
    end

    it "returns false" do
      klass._record_url_selector = nil
      klass._record_selector = "//items"
      klass.sitemap?.should be_false
    end
  end

  describe ".index_document" do
    let(:document) { Nokogiri::XML::Document.new }

    it "reads the raw xml and created a nokogiri document" do
      klass.stub(:index_xml) { "Some xml" }
      Nokogiri.should_receive(:parse).with("Some xml") { document }
      klass.index_document
    end
  end

  describe ".index_xml" do
    context "URL" do
      before do
        klass.base_url "http://google.com"
      end

      it "retrieves the XML from the URL" do
        RestClient.stub(:get).with("http://google.com") { "Some xml" }
        klass.index_xml.should eq "Some xml"
      end
    end

    context "File" do
      before do
        klass.base_url "file://harvester_core/integrations/source_data/sitemap_parser_urls.xml"
      end

      it "reads the xml list of url's from the file" do
        File.should_receive(:read).with("/harvester_core/integrations/source_data/sitemap_parser_urls.xml") { "Some xml" }
        klass.index_xml.should eq "Some xml"
      end
    end
  end

  describe ".fetch_records" do
    context "with a record_url_selector" do
      before { klass.stub(:sitemap?) { true } }

      it "initializes a set of sitemap records" do
        klass.should_receive(:sitemap_records).with(nil) { [] }
        klass.fetch_records
      end
    end

    context "with a record_selector" do
      before { klass.stub(:sitemap?) { false } }

      it "initializes a set of xml records" do
        klass.should_receive(:xml_records).with(nil) { [] }
        klass.fetch_records
      end
    end
  end

  describe "#.sitemap_records" do
    let(:xml) { File.read("spec/harvester_core/integrations/source_data/xml_parser_urls.xml") }

    before do
      klass.record_url_selector "//loc"
      klass.stub(:index_document) { Nokogiri.parse(xml) }
    end

    it "initializes a record for every url" do
      klass.should_receive(:new).once.with("http://www.nzonscreen.com/api/title/weekly-review-no-395-1949")
      klass.sitemap_records
    end
  end

  describe "#.xml_records" do
    let(:xml) { File.read("spec/harvester_core/integrations/source_data/xml_parser_records.xml") }
    let(:doc) { Nokogiri.parse(xml) }
    let!(:xml_snippets) { doc.xpath("//items/item") }

    before do
      klass.record_selector "//items/item"
      klass.stub(:index_document) { doc }
    end

    it "initializes a record with every section of the XML" do
      klass.should_receive(:new).once.with(xml_snippets.first) 
      klass.xml_records
    end
  end

  describe "#initialize" do
    it "initializes a sitemap record" do
      record = klass.new("http://google.com/1.html")
      record.url.should eq "http://google.com/1.html"
    end

    it "initializes a xml record" do
      node = mock(:node)
      record = klass.new(node)
      record.document.should eq node
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
      HarvesterCore::Utils.stub(:get) { "Some xml data" }
      Nokogiri.should_receive(:parse).with("Some xml data") { document }
      record.document
    end
  end
end