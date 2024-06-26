# frozen_string_literal: true

require 'spec_helper'

require_relative 'parsers/xml_tar_parser'

describe SupplejackCommon::Xml::Base do
  let!(:record) { XmlTarParser.records.first }

  context 'default values' do
    it 'defaults the collection to NZ On Screen' do
      expect(record.content_partner).to eq ['NZ On Screen']
    end
  end

  it 'gets the title' do
    expect(record.title).to eq ['Record 1']
  end
end
