# The Supplejack Common code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack_core 

require "spec_helper"

describe SupplejackCommon::XmlDocumentMethods do

	let(:klass) { SupplejackCommon::Xml::Base }

	after do
    klass.clear_definitions
  end

  describe ".xml_records" do
    let(:xml) { File.read("spec/supplejack_common/integrations/source_data/xml_parser_records.xml") }
    let(:doc) { Nokogiri.parse(xml) }
    let!(:xml_snippets) { doc.xpath("/g:items/g:item", {g: "http://digitalnz.org/schemas/test"}) }

    before do
      klass.record_selector "/g:items/g:item"
      klass.stub(:with_each_file).and_yield(xml)
      klass.stub(:parse_document) {doc}
      klass.namespaces g: "http://digitalnz.org/schemas/test"
      klass._request_timeout = 60000
    end

    it "initializes a record with every section of the XML" do
      klass.should_receive(:new).once.with(xml_snippets.first, anything)
      klass.xml_records("url")
    end

    it 'should set the total results if the xpath expression returns xpath node' do
      klass.stub(:pagination_options) { { total_selector: "/items/item/total" } }
      klass.xml_records("url")
      klass._total_results.should_not be_nil
    end

    it 'should set the total results if the xpath expression returns string' do
      klass.stub(:pagination_options) { { total_selector: "normalize-space(/items/item/total)" } }
      klass.xml_records("url")
      klass._total_results.should_not be_nil
    end
  end

  describe ".with_each_file" do
    let(:file) { mock(:file) }
    
    context "url is a url" do
      it "gets the url and yields it" do
        SupplejackCommon::Request.should_receive(:get).with('http://google.co.nz', 60000, anything) {file}
        expect{ |b| klass.send(:with_each_file, 'http://google.co.nz', &b) }.to yield_with_args(file) 
      end
    end

    context "url is a file" do
      it "opens the file and yields it" do
        File.should_receive(:read).with('/data/foo') {file}
        expect{ |b| klass.send(:with_each_file, 'file:///data/foo', &b) }.to yield_with_args(file) 
      end

      context "filename ends with .tar.gz" do
        let(:gzipped_file) {mock(:file)}
        let(:tar) { [mock(:file, file?: true, read: 'file1'),mock(:dir, file?: false),mock(:file, file?: true, read: 'file2')] }

        it "opens the tar and yields each file" do
          Zlib::GzipReader.should_receive(:open).with('/data/foo.tar.gz') {gzipped_file}
          Gem::Package::TarReader.should_receive(:new).with(gzipped_file) {tar}
          tar.should_receive(:rewind)

          expect{ |b| klass.send(:with_each_file, 'file:///data/foo.tar.gz', &b) }.to yield_successive_args("file1", "file2") 
        end
      end
    end
  end

  describe ".parse_document" do
    it "parses input file as html if the record format is html" do
      klass.record_format :html
      Nokogiri::HTML.should_receive(:parse).with("file")
      klass.send(:parse_document, "file")
    end

    it "parses input file as xml" do
      Nokogiri::XML.should_receive(:parse).with("file")
      klass.send(:parse_document, "file")
    end
  end

end