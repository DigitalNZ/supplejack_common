# frozen_string_literal: true

require 'spec_helper'

describe SupplejackCommon::Rss::Base do
  describe '.records' do
    it 'returns a paginated collection' do
      SupplejackCommon::PaginatedCollection.should_receive(:new).with(described_class, {}, {})
      described_class.records
    end
  end

  describe 'fetch_records' do
    let(:doc) { double(:nokogiri).as_null_object }
    let(:node) { double(:node).as_null_object }
    let(:url) { 'http://goo.gle' }

    before(:each) do
      described_class.stub(:index_document) { doc }
      described_class._namespaces = { dc: 'http://dc.com' }
      doc.stub(:xpath).with('//item', anything) { [node] }
    end

    it 'splits the xml into nodes for each RSS entry' do
      doc.should_receive(:xpath).with('//item', anything) { [node] }
      described_class.fetch_records(url)
    end

    it 'initializes a record with the RSS entry node' do
      described_class.should_receive(:new).with(node)
      described_class.fetch_records(url)
    end
  end

  describe '#initialize' do
    let(:xml) { '<record><title>Hi</title></record>' }
    let(:node) { double(:node, to_xml: xml).as_null_object }

    it 'initializes the record from xml' do
      record = described_class.new(xml)
      record.original_xml.should eq xml
    end

    it 'intializes the record from a node' do
      record = described_class.new(node)
      record.original_xml.should eq xml
    end
  end

  describe '#document' do
    let(:xml) { '<record><title>Hi</title></record>' }
    let(:record) { described_class.new(xml) }
    let(:document) { double(:document).as_null_object }

    it 'should parse the xml with Nokogiri' do
      Nokogiri::XML.should_receive(:parse).with(xml) { document }
      record.document.should eq document
    end
  end
end
