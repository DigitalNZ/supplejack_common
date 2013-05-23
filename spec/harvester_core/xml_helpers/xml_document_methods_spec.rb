require "spec_helper"

describe HarvesterCore::XmlDocumentMethods do

	let(:klass) { HarvesterCore::Xml::Base }

	after do
    klass.clear_definitions
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

end