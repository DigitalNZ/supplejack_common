# frozen_string_literal: true

require 'spec_helper'

require_relative 'parsers/xml_sitemap_parser'

describe SupplejackCommon::Xml::Base do
  before do
    urls_xml = File.read('spec/supplejack_common/integrations/source_data/xml_sitemap_parser_urls.xml')
    stub_request(:get, 'http://www.nzonscreen.com/api/title/').to_return(status: 200, body: urls_xml)

    record_xml = File.read('spec/supplejack_common/integrations/source_data/xml_sitemap_parser_record.xml')
    stub_request(:get, 'http://www.nzonscreen.com/api/title/weekly-review-no-395-1949').to_return(status: 200, body: record_xml)
  end

  let!(:record) { XmlSitemapParser.records.first }

  context 'default values' do
    it 'defaults the collection to NZ On Screen' do
      expect(record.content_partner).to eq ['NZ On Screen']
    end

    it 'defaults the category to Videos' do
      expect(record.category).to eq ['Videos']
    end
  end

  it 'gets the title' do
    expect(record.title).to eq ['Weekly Review No. 395']
  end

  it 'gets the record description' do
    expect(record.description).to eq ['This Weekly Review features: An interview with Sir Peter Buck in which Te Rangi Hīroa (then Medical Officer of Health for Maori) explains the sabbatical he took to research Polynesian anthropology']
  end

  it 'gets the date' do
    expect(record.date).to eq ['13:00:00, 29/01/2009']
  end

  it 'gets the tag' do
    expect(record.tag).to eq ['te rangi hīroa', 'public health', 'māori health', 'scenery']
  end

  it 'gets the thumbnail_url' do
    expect(record.thumbnail_url).to eq ['http://www.nzonscreen.com/content/images/0000/3114/weekly-review-395.jpg']
  end

  context 'overriden methods' do
    it 'gets the contributor' do
      expect(record.contributor).to eq ['Stanhope Andrews']
    end
  end
end
