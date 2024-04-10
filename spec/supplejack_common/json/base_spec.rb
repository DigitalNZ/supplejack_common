# frozen_string_literal: true

require 'spec_helper'

describe SupplejackCommon::Json::Base do
  let(:document) { double(:document) }
  let(:record) { double(:record).as_null_object }

  after { described_class.clear_definitions }

  describe '.record_selector' do
    it 'stores the path to retrieve every record metadata' do
      described_class.record_selector '$.items'
      expect(described_class._record_selector).to eq '$.items'
    end
  end

  describe '.records' do
    it 'returns a paginated collection' do
      expect(SupplejackCommon::PaginatedCollection).to receive(:new).with(described_class, {}, {})
      described_class.records
    end
  end

  describe '.records_json' do
    let(:json_example_1) { RestClient::Response.create('{"items": [{"title": "Record1"}, {"title": "Record2"}, {"title": "Record3"}]}', double.as_null_object, double.as_null_object) }
    let(:json_example_2) { RestClient::Response.create('{"items": {"title": "Record1"}}', double.as_null_object, double.as_null_object) }

    it 'returns an array of records with the parsed json' do
      allow(described_class).to receive(:document) { json_example_1 }
      described_class.record_selector '$.items'
      expect(described_class.records_json('http://goo.gle.com/1')).to eq [{ 'title' => 'Record1' }, { 'title' => 'Record2' }, { 'title' => 'Record3' }]
    end

    it 'returns an array of records with the parsed json when json object is not array' do
      allow(described_class).to receive(:document) { json_example_2 }
      described_class.record_selector '$.items'
      expect(described_class.records_json('http://goo.gle.com/1')).to eq [{ 'title' => 'Record1' }]
    end
  end

  describe '.document' do
    let(:json) { '"description": "Some json!"' }

    context 'json web document' do
      before do
        described_class._throttle = {}
        described_class.http_headers('Authorization': 'Token token="token"', 'x-api-key': 'gus')
        described_class._request_timeout = 60_000
        expect(SupplejackCommon::Request).to receive(:get).with('http://google.com', 60_000, {}, { 'Authorization': 'Token token="token"', 'x-api-key': 'gus' }, nil) { json }
      end

      it 'stores the raw json' do
        expect(described_class.document('http://google.com')).to eq json
      end

      it 'stores json document at _document class attribute' do
        described_class.document('http://google.com')
        expect(described_class._document).to equal json
      end

      it 'pre process json data if pre_process_block DSL is defined' do
        new_json = { a_new_json: 'Some value' }
        described_class.pre_process_block { new_json }

        described_class.document('http://google.com')
        expect(described_class._document).to equal new_json
      end
    end

    context 'json files' do
      it 'stores the raw json' do
        expect(File).to receive(:read).with('file:///data/sites/data.json'.gsub(%r{file:\/\/}, '')) { json }
        expect(described_class.document('file:///data/sites/data.json')).to eq json
      end
    end

    context 'scroll api' do
      it 'stores the raw json from _scroll' do
        described_class._throttle = {}
        described_class.http_headers('x-api-key': 'key')
        described_class._request_timeout = 60_000
        expect(SupplejackCommon::Request).to receive(:scroll).with('http://google.com/_scroll', 60_000, {}, 'x-api-key': 'key') { json }
        described_class.document('http://google.com/_scroll')
        expect(described_class._document).to eq json
      end

      it 'stores the raw json from /scroll' do
        described_class._throttle = {}
        described_class.http_headers('x-api-key': 'key')
        described_class._request_timeout = 60_000
        expect(SupplejackCommon::Request).to receive(:scroll).with('http://google.com/scroll', 60_000, {}, 'x-api-key': 'key') { json }
        described_class.document('http://google.com/scroll')
        expect(described_class._document).to eq json
      end
    end
  end

  describe '.total_results' do
    let(:json) { { 'description' => 'Some json!', 'total_results_selector' => 500 }.to_json }
    it 'returns the total results from the json document' do
      described_class._throttle = {}
      described_class.http_headers('Authorization' => 'Token token="token"', 'x-api-key' => 'gus')
      described_class._request_timeout = 60_000
      expect(SupplejackCommon::Request).to receive(:get).with('http://google.com', 60_000, {}, { 'Authorization' => 'Token token="token"', 'x-api-key' => 'gus' }, nil) { json }
      described_class.document('http://google.com')
      expect(described_class.total_results('$.total_results_selector')).to eq 500.0
    end
  end

  describe '.next_page_token' do
    let(:json) { { 'description' => 'Some json!', 'your_next_page' => '1234' }.to_json }
    it 'returns the total results from the json document' do
      described_class._throttle = {}
      described_class.http_headers('Authorization' => 'Token token="token"', 'x-api-key' => 'gus')
      described_class._request_timeout = 60_000
      expect(SupplejackCommon::Request).to receive(:get).with('http://google.com', 60_000, {}, { 'Authorization' => 'Token token="token"', 'x-api-key' => 'gus' }, nil) { json }
      described_class.document('http://google.com')
      expect(described_class.next_page_token('$.your_next_page')).to eq '1234'
    end
  end

  describe '.fetch_records' do
    let(:document) { { 'location' => 1234 } }

    before do
      allow(described_class).to receive(:records_json) { [{ 'title' => 'Record1' }] }
      allow(described_class).to receive(:document) { document }
    end

    it 'initializes record for every json record' do
      expect(described_class).to receive(:new).once.with('title' => 'Record1') { record }
      expect(described_class.fetch_records('http://google.com')).to eq [record]
    end

    context 'pagination options defined' do
      before do
        allow(described_class).to receive(:pagination_options) { { total_selector: 'totalResults' } }
      end

      it 'should set the total results if the json expression returns string' do
        expect(JsonPath).to receive(:on).with(described_class._document, 'totalResults') { [22] }
        expect(described_class.total_results('totalResults')).to eq 22
      end
    end
  end

  describe '.clear_definitions' do
    it 'clears the _record_selector' do
      described_class.record_selector 'path'
      described_class.clear_definitions
      expect(described_class._record_selector).to be_nil
    end

    it 'clears the _document' do
      described_class._document = { a: 123 }
      described_class.clear_definitions
      expect(described_class._document).to be_nil
    end
  end

  describe '#initialize' do
    it "initializes the record's attributes" do
      record = described_class.new('title' => 'Dos')
      expect(record.json).to eq('{"title":"Dos"}')
    end

    it 'returns an empty string when attributes are nil' do
      record = described_class.new(nil)
      expect(record.json).to eq('')
    end

    it 'initializes from a json string' do
      data = { 'title' => 'Hi' }.to_json
      record = described_class.new(data)
      expect(record.document).to eq('{"title":"Hi"}')
    end
  end

  describe '#full_raw_data' do
    let(:record) { described_class.new('title' => 'Hi') }

    it 'should convert the raw_data to json' do
      expect(record.full_raw_data).to eq({ 'title' => 'Hi' }.to_json)
    end
  end

  describe '#strategy_value' do
    let(:record) { described_class.new('dc:creator' => 'John', 'dc:author' => 'Fede') }

    it 'returns the value of a attribute' do
      expect(record.strategy_value(path: "$.'dc:creator'")).to eq ['John']
    end

    it 'returns the values from multiple paths' do
      expect(record.strategy_value(path: ["$.'dc:creator'", "$.'dc:author'"])).to eq %w[John Fede]
    end

    it 'returns nil without :path' do
      expect(record.strategy_value(path: nil)).to be_nil
    end
  end

  describe '#fetch' do
    let(:record) { described_class.new('dc:creator' => 'John', 'dc:author' => 'Fede') }
    let(:document) { { 'location' => 1234 } }

    before { allow(record).to receive(:document) { document } }

    it 'returns the value object' do
      value = record.fetch('location')
      expect(value).to be_a SupplejackCommon::AttributeValue
      expect(value.to_a).to eq [1234]
    end
  end
end
