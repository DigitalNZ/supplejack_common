# frozen_string_literal: true

require 'spec_helper'

describe SupplejackCommon::Sitemap::PaginatedCollection do
  class PaginatedTestXml < SupplejackCommon::Xml::Base; end

  let(:collection) { described_class.new(PaginatedTestXml) }
  let(:document) { double(:document) }
  let(:sitemap_klass) { SupplejackCommon::Sitemap::Base }

  it 'initializes the klass, sitemap_klass with a sitemap_entry_selector and options' do
    collection = described_class.new(PaginatedTestXml)

    expect(collection.klass).to eq PaginatedTestXml
    expect(collection.sitemap_klass).to eq sitemap_klass
    expect(collection.options).to eq({})
  end

  it 'calls sitemap_entry_selector on sitemap_klass with the selector passed through' do
    PaginatedTestXml.sitemap_entry_selector '//loc'

    expect(collection.sitemap_klass).to receive(:sitemap_entry_selector).with('//loc')

    described_class.new(PaginatedTestXml)
  end

  it 'adds the namespaces to the site' do
    PaginatedTestXml.namespaces page: 'http://www.w3.org/1999/xhtml'

    expect(collection.sitemap_klass).to receive(:_namespaces=).with(
      hash_including({ page: 'http://www.w3.org/1999/xhtml' })
    )

    described_class.new(PaginatedTestXml)
  end

  describe '#each' do
    before do
      allow(PaginatedTestXml).to receive_messages(base_urls: ['http://goog.le'], fetch_records: '<xml>1<xml>')
      allow(collection).to receive(:yield_from_records).and_return(true)
    end

    it 'fetches the entries from the site map' do
      expect(sitemap_klass).to receive(:fetch_entries).with('http://goog.le').and_return(['http://goo.gl/1.xml', 'http://goo.gl/2.xml'])
      collection.each { |record| }

      expect(collection.instance_variable_get(:@entries)).to eq ['http://goo.gl/1.xml', 'http://goo.gl/2.xml']
    end

    it 'fetches the records for the provided strategy then stores them in @records' do
      xml_1 = double(:text_xml)
      xml_2 = double(:text_xml)
      allow(sitemap_klass).to receive(:fetch_entries).and_return(['http://goo.gl/1.xml'])

      expect(PaginatedTestXml).to receive(:fetch_records).with('http://goo.gl/1.xml') { [xml_1, xml_2] }

      collection.each { |record| }

      expect(collection.instance_variable_get(:@records)).to include(xml_1, xml_2)
    end

    it 'calls yield from records for each entry' do
      expect(collection).to receive(:yield_from_records).twice

      allow(sitemap_klass).to receive(:fetch_entries).and_return(['http://goo.gl/1.xml', 'http://goo.gl/2.xml'])
      collection.each { |record| }
    end

    context 'multiple base urls' do
      before do
        allow(PaginatedTestXml).to receive(:base_urls).and_return(['http://goog.le', 'http://dnz.com/1'])
        allow(collection).to receive(:entries).and_return([])
      end

      it 'handles multiple sitemap base_urls' do
        expect(SupplejackCommon::Sitemap::Base).to receive(:fetch_entries).with('http://goog.le').and_return([])
        expect(SupplejackCommon::Sitemap::Base).to receive(:fetch_entries).with('http://dnz.com/1').and_return([])
        collection.each { |record| }
      end
    end
  end
end
