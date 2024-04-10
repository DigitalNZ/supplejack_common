# frozen_string_literal: true

require 'spec_helper'

require_relative 'parsers/xml_parser'

describe SupplejackCommon::Xml::Base do
  before do
    xml = File.read('spec/supplejack_common/integrations/source_data/xml_parser_records.xml')
    stub_request(:get, 'http://digitalnz.org/xml').to_return(status: 200, body: xml)
  end

  let!(:record) { XmlParser.records.first }

  context 'default values' do
    it 'defaults the collection to NZ On Screen' do
      expect(record.content_partner).to eq ['NZ On Screen']
    end
  end

  it 'gets the title' do
    expect(record.title).to eq ['Page 4 Advertisements Column 4 (Otago Daily Times, 02 April 1888)']
  end

  it 'gets the record description' do
    expect(record.description).to eq ['A thing']
  end

  it 'gets the date' do
    expect(record.date).to eq ['2011-02-13 14:09:03 +1300']
  end

  it 'gets the display_date using fetch' do
    expect(record.display_date).to eq ['2011-02-13 14:09:03 +1300']
  end

  it 'gets the author' do
    expect(record.author).to eq ['Andy']
  end
end
