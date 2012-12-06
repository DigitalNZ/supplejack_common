require "spec_helper"

describe DnzHarvester::Sitemap::Base do
  
  let(:klass) { DnzHarvester::Sitemap::Base }
  let(:file) { mock(:file) }
  let(:record) { mock(:record) }

  after do
    klass._base_urls[klass.identifier] = []
    klass._attribute_definitions[klass.identifier] = {}
  end

  describe ".sitemap_file" do
    it "reads the contents of the sitemap" do
      klass.base_url "/path/to/file/sitemap.xml"
      File.should_receive(:read).with("/path/to/file/sitemap.xml") { file }
      klass.sitemap_file.should eq file
    end
  end

  describe ".sitemap_document" do
    it "parses the sitemap_file" do
      klass.stub(:sitemap_file) { file }
      Nokogiri.should_receive(:parse).with(file)
      klass.sitemap_document
    end
  end

  describe ".record_urls" do
    it "returns a list of the sitemap url's" do
      klass.stub(:sitemap_file) { File.read("spec/dnz_harvester/integrations/source_data/sitemap_parser_urls.xml") }
      klass.record_urls.should eq ["http://www.nzmuseums.co.nz/account/3700/object/145276/Attenhofer_A15_Swing_Jet_ski"]
    end
  end

  describe ".records" do
    it "initializes a record for every url" do
      klass.stub(:record_urls) { ["http://www.nzmuseums.com/1"] }
      klass.should_receive(:new).once.with("http://www.nzmuseums.com/1") { record }
      klass.records.should eq [record]
    end
  end

  describe "#initialize" do
    it "assigns the url" do
      record = klass.new("http://google.com")
      record.url.should eq "http://google.com"
    end
  end

  describe "#document" do
    let(:document) { mock(:document) }
    let(:record) { klass.new("http://google.com") }

    it "parses the record xml" do
      DnzHarvester::Utils.stub(:get) { "Some xml data" }
      Nokogiri.should_receive(:parse).with("Some xml data") { document }
      record.document
    end
  end
end