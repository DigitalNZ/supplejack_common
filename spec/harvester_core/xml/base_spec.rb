require "spec_helper"

describe HarvesterCore::Xml::Base do
  
  let(:klass) { HarvesterCore::Xml::Base }
  let(:document) { mock(:document) }

  after do
    klass.clear_definitions
  end

  describe ".record_url_selector" do
    it "stores the xpath to retrieve every record url" do
      klass.record_url_selector "loc"
      klass._record_url_selector.should eq "loc"
    end
  end

  describe ".record_format" do
    it "stores the format of the actual record" do
      klass.record_format :xml
      klass._record_format.should eq :xml
    end
  end

  describe ".record_selector" do
    it "stores the xpath to retrieve every record" do
      klass.record_selector "//items/item"
      klass._record_selector.should eq "//items/item"
    end
  end

  describe ".sitemap_format" do
    it "stores the format of the actual record" do
      klass.sitemap_format :xml
      klass._sitemap_format.should eq :xml
    end
  end

  describe ".sitemap_format_class" do
    it "should return the Nokogiri::XML class" do
      klass.sitemap_format :xml
      klass.sitemap_format_class.should eq Nokogiri::XML
    end

    it "should return the Nokogiri::HTML class" do
      klass.sitemap_format :html
      klass.sitemap_format_class.should eq Nokogiri::HTML
    end

    it "should default to Nokogiri::HTML" do
      klass.sitemap_format_class.should eq Nokogiri::HTML
    end

    it "should fallback to Nokogiri::HTML when the format is invalid" do
      klass.sitemap_format :json
      klass.sitemap_format_class.should eq Nokogiri::HTML
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
      Nokogiri::XML.should_receive(:parse).with("Some xml") { document }
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

  describe ".sitemap_records" do
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

  describe ".xml_records" do
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

  describe ".clear_definitions" do
    it "clears the record_url_selector" do
      klass.record_url_selector "//loc"
      klass.clear_definitions
      klass._record_url_selector.should be_nil
    end

    it "clears the record_selector" do
      klass.record_selector "//item"
      klass.clear_definitions
      klass._record_selector.should be_nil
    end

    it "clears the total results" do
      klass._total_results = 100
      klass.clear_definitions
      klass._total_results.should be_nil
    end
  end

  describe "#initialize" do
    it "initializes a sitemap record" do
      record = klass.new("http://google.com/1.html")
      record.url.should eq "http://google.com/1.html"
    end

    it "initializes a xml record" do
      node = mock(:node, to_xml: "<record></record>")
      record = klass.new(node)
      record.document.should eq node
    end

    it "initializes from raw xml" do
      xml = "<record></record>"
      record = klass.new(xml, true)
      record.original_xml.should eq xml
    end
  end

  describe "#format" do
    context "sitemap records" do
      it "defaults to HTML" do
        klass.new("http://google.com/1").format.should eq :html
      end

      it "returns XML when format is explicit at the klass level" do
        klass.record_format :xml
        klass.new("http://google.com/1").format.should eq :xml
      end
    end

    context "records from single XML" do
      it "default to XML for a raw record" do
        klass.new("<record/>", true).format.should eq :xml
      end

      it "returns HTML when format is explicit for raw records" do
        klass.record_format :html
        klass.new("<body/>", true).format.should eq :html
      end
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

    context "format is XML" do
      let(:xml) { "<record>Some xml data</record>" }

      before do
        record.stub(:format) { :xml }
        HarvesterCore::Request.stub(:get) { xml }
        HarvesterCore::Utils.stub(:remove_default_namespace).with(xml) { xml }
      end

      it "requets a record and removes the default namespace" do
        HarvesterCore::Request.should_receive(:get) { xml }
        HarvesterCore::Utils.should_receive(:remove_default_namespace).with(xml) { xml }
        Nokogiri::XML.should_receive(:parse).with(xml) { document }
        record.document.should eq document
      end

      it "should not add a HTML tag" do
        HarvesterCore::Utils.should_not_receive(:add_html_tag)
        record.document
      end

      it "builds a document from original_xml" do
        record = klass.new("<record>other data</record>", true)
        record.document.to_xml.should eq "<?xml version=\"1.0\"?>\n<record>other data</record>\n"
      end
    end

    context "format is HTML" do
      let(:html) { "<html>Some data</html>" }

      before do
        record.stub(:format) { :html }
        HarvesterCore::Request.stub(:get) { html }
      end

      it "parses the requested HTML" do
        HarvesterCore::Request.should_receive(:get) { html }
        record.document
      end

      it "should not remove the default namespace" do
        HarvesterCore::Utils.should_not_receive(:remove_default_namespace)
        record.document
      end

      it "should parse the HTML document" do
        Nokogiri::HTML.should_receive(:parse).with("<html>Some data</html>")
        record.document
      end
    end
  end

  describe "raw_data" do
    let(:xml) do
<<-XML
<?xml version="1.0"?>
<document>
<item><title>Hi</title></item>
<item><title>Hi2</title></item>
</document>
XML
    end
    let(:document) { Nokogiri::XML.parse(xml) }

    context "full xml document" do
      let(:record) { klass.new("http://google.com/1") }

      before(:each) do
        record.stub(:document) { document }
      end

      it "returns the full xml document" do
        record.raw_data.should eq(xml)
      end
    end

    context "node within xml document" do
      let(:record) { klass.new(document.xpath("//item").first) }

      it "returns the snippet corresponding to the record" do
        record.raw_data.should eq("<item>
  <title>Hi</title>
</item>")
      end
    end
  end
end