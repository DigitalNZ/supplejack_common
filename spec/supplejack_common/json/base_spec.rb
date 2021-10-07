# frozen_string_literal: true

require 'spec_helper'

describe SupplejackCommon::Json::Base do
  let(:document) { double(:document) }
  let(:record) { double(:record).as_null_object }

  after { described_class.clear_definitions }

  describe '.record_selector' do
    it 'stores the path to retrieve every record metadata' do
      described_class.record_selector '$.items'
      described_class._record_selector.should eq '$.items'
    end
  end

  describe '.records' do
    it 'returns a paginated collection' do
      SupplejackCommon::PaginatedCollection.should_receive(:new).with(described_class, {}, {})
      described_class.records
    end
  end

  describe '.records_json' do
    let(:json_example_1) { RestClient::Response.create('{"items": [{"title": "Record1"}, {"title": "Record2"}, {"title": "Record3"}]}', double.as_null_object, double.as_null_object) }
    let(:json_example_2) { RestClient::Response.create('{"items": {"title": "Record1"}}', double.as_null_object, double.as_null_object) }

    it 'returns an array of records with the parsed json' do
      described_class.stub(:document) { json_example_1 }
      described_class.record_selector '$.items'
      described_class.records_json('http://goo.gle.com/1').should eq [{ 'title' => 'Record1' }, { 'title' => 'Record2' }, { 'title' => 'Record3' }]
    end

    it 'returns an array of records with the parsed json when json object is not array' do
      described_class.stub(:document) { json_example_2 }
      described_class.record_selector '$.items'
      described_class.records_json('http://goo.gle.com/1').should eq [{ 'title' => 'Record1' }]
    end
  end

  describe '.document' do
    let(:json) { '"description": "Some json!"' }

    context 'json web document' do
      before do
        described_class._throttle = {}
        described_class.http_headers('Authorization': 'Token token="token"', 'x-api-key': 'gus')
        described_class._request_timeout = 60_000
        SupplejackCommon::Request.should_receive(:get).with('http://google.com', 60_000, {}, { 'Authorization': 'Token token="token"', 'x-api-key': 'gus' }, nil) { json }
      end

      it 'stores the raw json' do
        described_class.document('http://google.com').should eq json
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
        File.should_receive(:read).with('file:///data/sites/data.json'.gsub(%r{file:\/\/}, '')) { json }
        described_class.document('file:///data/sites/data.json').should eq json
      end
    end

    context 'scroll api' do
      it 'stores the raw json from _scroll' do
        described_class._throttle = {}
        described_class.http_headers('x-api-key': 'key')
        described_class._request_timeout = 60_000
        SupplejackCommon::Request.should_receive(:scroll).with('http://google.com/_scroll', 60_000, {}, 'x-api-key': 'key') { json }
        described_class.document('http://google.com/_scroll')
        expect(described_class._document).to eq json
      end

      it 'stores the raw json from /scroll' do
        described_class._throttle = {}
        described_class.http_headers('x-api-key': 'key')
        described_class._request_timeout = 60_000
        SupplejackCommon::Request.should_receive(:scroll).with('http://google.com/scroll', 60_000, {}, 'x-api-key': 'key') { json }
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
      SupplejackCommon::Request.should_receive(:get).with('http://google.com', 60_000, {}, { 'Authorization' => 'Token token="token"', 'x-api-key' => 'gus' }, nil).and_return { json }
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
      SupplejackCommon::Request.should_receive(:get).with('http://google.com', 60_000, {}, { 'Authorization' => 'Token token="token"', 'x-api-key' => 'gus' }, nil).and_return { json }
      described_class.document('http://google.com')
      expect(described_class.next_page_token('$.your_next_page')).to eq '1234'
    end
  end

  describe '.fetch_records' do
    let(:document) { { 'location' => 1234 } }

    before do
      described_class.stub(:records_json) { [{ 'title' => 'Record1' }] }
      described_class.stub(:document) { document }
    end

    it 'initializes record for every json record' do
      described_class.should_receive(:new).once.with('title' => 'Record1') { record }
      described_class.fetch_records('http://google.com').should eq [record]
    end

    context 'pagination options defined' do
      before do
        described_class.stub(:pagination_options) { { total_selector: 'totalResults' } }
      end

      it 'should set the total results if the json expression returns string' do
        JsonPath.should_receive(:on).with(described_class._document, 'totalResults') { [22] }
        described_class.total_results('totalResults').should eq 22
      end
    end
  end

  describe '.clear_definitions' do
    it 'clears the _record_selector' do
      described_class.record_selector 'path'
      described_class.clear_definitions
      described_class._record_selector.should be_nil
    end

    it 'clears the _document' do
      described_class._document = { a: 123 }
      described_class.clear_definitions
      described_class._document.should be_nil
    end
  end

  describe '#initialize' do
    it "initializes the record's attributes" do
      record = described_class.new('title' => 'Dos')
      record.json.should eq('{"title":"Dos"}')
    end

    it 'returns an empty string when attributes are nil' do
      record = described_class.new(nil)
      record.json.should eq('')
    end

    it 'initializes from a json string' do
      data = { 'title' => 'Hi' }.to_json
      record = described_class.new(data)
      record.document.should eq('{"title":"Hi"}')
    end
  end

  describe '#full_raw_data' do
    let(:record) { described_class.new('title' => 'Hi') }

    it 'should convert the raw_data to json' do
      record.full_raw_data.should eq({ 'title' => 'Hi' }.to_json)
    end
  end

  describe '#strategy_value' do
    let(:record) { described_class.new('dc:creator' => 'John', 'dc:author' => 'Fede') }

    it 'returns the value of a attribute' do
      record.strategy_value(path: "$.'dc:creator'").should eq ['John']
    end

    it 'returns the values from multiple paths' do
      record.strategy_value(path: ["$.'dc:creator'", "$.'dc:author'"]).should eq %w[John Fede]
    end

    it 'returns nil without :path' do
      record.strategy_value(path: nil).should be_nil
    end
  end

  describe '#fetch' do
    let(:record) { described_class.new('dc:creator' => 'John', 'dc:author' => 'Fede') }
    let(:document) { { 'location' => 1234 } }

    before { record.stub(:document) { document } }

    it 'returns the value object' do
      value = record.fetch('location')
      value.should be_a SupplejackCommon::AttributeValue
      value.to_a.should eq [1234]
    end
  end
end
