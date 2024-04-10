# frozen_string_literal: true

require 'spec_helper'

require_relative 'parsers/rss_parser'

describe SupplejackCommon::Rss::Base do
  before(:all) do
    rss_xml = File.read(File.dirname(__FILE__) + '/source_data/rss_parser.xml')
    @document = Nokogiri.parse(rss_xml)
  end

  before do
    allow(RssParser).to receive(:index_document) { @document }
  end

  let!(:record) { RssParser.records.first }

  context 'default values' do
    it 'defaults the catefory to Newspapers' do
      expect(record.category).to include('Newspapers')
    end
  end

  it 'gets the record title' do
    expect(record.title).to eq ['Cottrell murder accused initially treated as witness']
  end

  it 'gets the record description' do
    expect(record.description).to eq ['One of two men charged with murdering Wellington journalist Phillip Cottrell was initially treated as a witness, a jury has heard.']
  end

  it 'gets the record date' do
    expect(record.date).to eq [Time.parse('2012-12-05 03:52:00 UTC')]
  end

  it 'gets the record landing_url' do
    expect(record.landing_url).to eq ['http://www.3news.co.nz/Cottrell-murder-accused-initially-treated-as-witness/tabid/423/articleID/279322/Default.aspx']
  end

  it 'gets the record thumbnail_url' do
    expect(record.thumbnail_url).to eq ['http://cdn.3news.co.nz/3news/AM/2012/12/5/279322/Manuel-Robinson-Nicho-Waipuka-1200.jpg?width=180']
  end

  context 'overriden methods' do
    it 'generates a large_thumbnail_url from the thumbnail_url' do
      expect(record.large_thumbnail_url).to eq ['http://cdn.3news.co.nz/3news/AM/2012/12/5/279322/Manuel-Robinson-Nicho-Waipuka-1200.jpg?width=520']
    end

    it 'adds a Images values to the category' do
      expect(record.category).to eq %w[Newspapers Images]
    end
  end
end
