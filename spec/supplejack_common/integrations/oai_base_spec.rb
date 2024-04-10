# frozen_string_literal: true

require 'spec_helper'

require_relative 'parsers/oai_parser'

describe SupplejackCommon::Oai::Base do
  context 'normal records' do
    before do
      body = File.read(File.dirname(__FILE__) + '/source_data/oai_library.xml')
      stub_request(:get, 'http://library.org/?metadataPrefix=oai_dc&verb=ListRecords').to_return(status: 200, body:)

      allow_any_instance_of(OAI::Client).to receive(:strip_invalid_utf_8_chars).with(body).and_return(body)
    end

    let!(:record) { OaiParser.records.first }

    context 'default values' do
      it 'defaults the category to Research papers' do
        expect(record.category).to eq ['Research papers']
      end
    end

    it 'gets the record title' do
      expect(record.title).to eq ['Selected resonant converters for IPT power supplies']
    end

    it 'gets the record identifier' do
      expect(record.identifier).to eq ['oai:researchspace.auckland.ac.nz:2292/3']
    end

    context 'overriden methods' do
      it 'generates a enrichment_url from the identifier' do
        expect(record.enrichment_url).to eq ['https://researchspace.auckland.ac.nz/handle/2292/3?show=full']
      end
    end
  end

  context 'incremental harvest' do
    before do
      body = File.read(File.dirname(__FILE__) + '/source_data/oai_library_inc.xml')
      stub_request(:get, 'http://library.org/?metadataPrefix=oai_dc&verb=ListRecords&from=2012-11-10').to_return(status: 200, body:)

      allow_any_instance_of(OAI::Client).to receive(:strip_invalid_utf_8_chars).with(body).and_return(body)
    end

    context 'changed records' do
      let!(:record) { OaiParser.records(from: Date.parse('2012-11-10')).first }

      it 'gets the record title' do
        expect(record.title).to eq ['Natural Algorithms']
      end
    end
  end
end
