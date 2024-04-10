# frozen_string_literal: true

require 'spec_helper'

require_relative 'parsers/json_parser'

describe SupplejackCommon::Json::Base do
  before do
    json = File.read('spec/supplejack_common/integrations/source_data/json_records.json')
    stub_request(:get, 'http://api.europeana.eu/records.json').to_return(status: 200, body: json)
  end

  let!(:record) { JsonParser.records.first }

  context 'default values' do
    it 'defaults the collection to Europeana' do
      expect(record.collection).to eq ['Europeana']
    end
  end

  it 'gets the title' do
    expect(record.title).to eq ['Transactions and proceedings of the New Zealand Institute. Volume v.30 (1897)']
  end

  it 'gets the record description' do
    expect(record.description).to eq ['New Zealand Instit...']
  end

  it 'gets the creator' do
    expect(record.creator).to eq ['New Zealand Institute (Wellington, N.Z']
  end

  it 'gets the language' do
    expect(record.language).to eq ['mul']
  end

  it 'gets the dnz_type' do
    expect(record.dnz_type).to eq ['TEXT']
  end

  it 'gets the contributing_partner' do
    expect(record.contributing_partner).to eq ['NCSU Libraries (archive.org)']
  end

  it 'gets the thumbnail_url' do
    expect(record.thumbnail_url).to eq ['http://bhl.ait.co.at/templates/bhle/sampledata/cachedImage.php?maxSize=200&filename=http://www.biodiversitylibrary.org/pagethumb/25449335']
  end

  it 'gets nested keys' do
    expect(record.tags).to eq ['foo']
  end

  context 'overriden methods' do
    it 'gets the landing_url' do
      expect(record.landing_url).to eq ['http://www.europeana.eu/portal/record/08701/533BD2421E162B12D599BBCC3BF0BA3C516A8CFB']
    end
  end
end
