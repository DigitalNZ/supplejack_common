# frozen_string_literal: true

require 'spec_helper'

describe SupplejackCommon::Oai::PaginatedCollection do
  class TestSource < SupplejackCommon::Oai::Base; end

  let(:client) { double(:client) }
  let(:options) { {} }
  let(:klass) { double(:klass) }
  let(:record) { double(:record).as_null_object }

  it 'initializes the client, options and klass' do
    collection = SupplejackCommon::Oai::PaginatedCollection.new(client, options, klass)
    expect(collection.client).to eq client
    expect(collection.options).to eq options
    expect(collection.klass).to eq klass
  end

  it 'initializes the limit' do
    expect(SupplejackCommon::Oai::PaginatedCollection.new(client, { limit: 10 }, klass).limit).to eq 10
  end

  describe '#each' do
    let(:collection) { SupplejackCommon::Oai::PaginatedCollection.new(client, {}, TestSource) }

    before do
      list = double(:list, full: [record, record])
      allow(collection).to receive(:client) { double(:client, list_records: list) }
    end

    it 'stops iterating when the limit is reached' do
      allow(collection).to receive(:limit) { 1 }
      records = collection.map { |r| r }
      expect(records.size).to eq 1
    end

    it 'initializes a new TestSource record for every oai record' do
      expect(TestSource).to(receive(:new).twice { record })
      collection.each { |r| r }
    end

    it 'returns a array of TestSource records' do
      records = collection.map { |r| r }
      expect(records.first).to be_a(TestSource)
    end
  end
end
