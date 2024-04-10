# frozen_string_literal: true

require 'spec_helper'

describe SupplejackCommon::XmlDocumentMethods do
  let(:klass) { SupplejackCommon::Xml::Base }

  after { klass.clear_definitions }

  describe '.xml_records' do
    let(:xml) { File.read('spec/supplejack_common/integrations/source_data/xml_parser_records.xml') }
    let(:doc) { Nokogiri.parse(xml) }
    let!(:xml_snippets) { doc.xpath('/g:items/g:item', g: 'http://digitalnz.org/schemas/test') }

    before do
      klass.record_selector '/g:items/g:item'
      allow(klass).to receive(:with_each_file).and_yield(xml)
      klass.namespaces g: 'http://digitalnz.org/schemas/test'
      klass._request_timeout = 60_000
    end

    it 'pre process xml data if pre_process_block DSL is defined' do
      new_xml = '<a-new-xml>Some value</a-new-xml>'
      klass.pre_process_block { new_xml }

      klass.xml_records('url')
      expect(klass._document.to_s).to eq Nokogiri::XML.parse(new_xml).to_s
    end

    it 'initializes a record with every section of the XML' do
      allow(klass).to receive(:parse_document) { doc }
      expect(klass).to receive(:new).once.with(xml_snippets.first, anything)
      klass.xml_records('url')
    end

    it 'should set the total results if the xpath expression returns xpath node' do
      allow(klass).to receive(:pagination_options) { { total_selector: '/items/item/total' } }
      klass.xml_records('url')
      expect(klass._total_results).not_to be_nil
    end

    it 'should set the total results if the xpath expression returns string' do
      allow(klass).to receive(:pagination_options) { { total_selector: 'normalize-space(/items/item/total)' } }
      klass.xml_records('url')
      expect(klass._total_results).not_to be_nil
    end
  end

  describe '.with_each_file' do
    let(:file) { double(:file) }

    context 'url is a url' do
      it 'gets the url and yields it' do
        expect(SupplejackCommon::Request).to receive(:get).with('http://google.co.nz', 60_000, anything, anything, anything) { file }
        expect { |b| klass.send(:with_each_file, 'http://google.co.nz', &b) }.to yield_with_args(file)
      end
    end

    context 'url is a file' do
      it 'opens the file and yields it' do
        expect(File).to receive(:read).with('/data/foo') { file }
        expect { |b| klass.send(:with_each_file, 'file:///data/foo', &b) }.to yield_with_args(file)
      end

      context 'filename ends with .tar.gz' do
        let(:gzipped_file) { double(:file) }
        let(:tar) { [double(:file, file?: true, read: 'file1'), double(:dir, file?: false), double(:file, file?: true, read: 'file2')] }

        it 'opens the tar and yields each file' do
          expect(Zlib::GzipReader).to receive(:open).with('/data/foo.tar.gz') { gzipped_file }
          expect(Gem::Package::TarReader).to receive(:new).with(gzipped_file) { tar }
          expect(tar).to receive(:rewind)

          expect { |b| klass.send(:with_each_file, 'file:///data/foo.tar.gz', &b) }.to yield_successive_args('file1', 'file2')
        end
      end
    end
  end

  describe '.parse_document' do
    it 'parses input file as html if the record format is html' do
      klass.record_format :html
      expect(Nokogiri::HTML).to receive(:parse).with('file')
      klass.send(:parse_document, 'file')
    end

    it 'parses input file as xml' do
      expect(Nokogiri::XML).to receive(:parse).with('file')
      klass.send(:parse_document, 'file')
    end
  end
end
