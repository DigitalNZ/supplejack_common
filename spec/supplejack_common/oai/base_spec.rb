# frozen_string_literal: true

require 'spec_helper'

describe SupplejackCommon::Oai::Base do
  let(:header) { double(:header, identifier: '123') }
  let(:root) { double(:root).as_null_object }
  let(:oai_record) { double(:oai_record, header:, metadata: [root]).as_null_object }
  let(:record) { described_class.new(oai_record) }

  before do
    described_class._base_urls[described_class.identifier] = []
    described_class._attribute_definitions[described_class.identifier] = {}
    described_class.clear_definitions
  end

  describe '.client' do
    it 'initializes a new OAI client' do
      described_class.base_url 'http://google.com'
      expect(OAI::Client).to receive(:new).with('http://google.com', {}, nil)
      described_class.client
    end
  end

  describe '#metadata_prefix' do
    it 'gets the metadata prefix' do
      described_class.metadata_prefix 'prefix'
      expect(described_class.get_metadata_prefix).to eq 'prefix'
    end
  end

  describe '#set' do
    it 'gets the set name' do
      described_class.set 'name'
      expect(described_class.get_set).to eq 'name'
    end
  end

  describe '.records' do
    let(:client) { double(:client) }
    let!(:paginator) { double(:paginator) }

    before(:each) do
      allow(described_class).to receive(:client) { client }
    end

    it 'initializes a PaginatedCollection with the results' do
      expect(SupplejackCommon::Oai::PaginatedCollection).to receive(:new).with(client, {}, described_class) { paginator }
      described_class.records
    end

    it 'accepts a :from option and pass it on to list_records' do
      date = Date.today
      expect(SupplejackCommon::Oai::PaginatedCollection).to receive(:new).with(client, { from: date }, described_class) { paginator }
      described_class.records(from: date)
    end

    it 'accepts a :limit option' do
      expect(SupplejackCommon::Oai::PaginatedCollection).to receive(:new).with(client, { limit: 10 }, described_class) { paginator }
      described_class.records(limit: 10)
    end

    it 'add the :metadata_prefix option from the DSL' do
      expect(SupplejackCommon::Oai::PaginatedCollection).to receive(:new).with(client, { metadata_prefix: 'prefix' }, described_class) { paginator }

      described_class.metadata_prefix 'prefix'
      described_class.records
    end

    it 'add the :set option from the DSL' do
      expect(SupplejackCommon::Oai::PaginatedCollection).to receive(:new).with(client, { set: 'name' }, described_class) { paginator }

      described_class.set 'name'
      described_class.records
    end

    it 'does not pass on unknown options' do
      expect(SupplejackCommon::Oai::PaginatedCollection).not_to receive(:new).with(client, { golf_scores: :all }, described_class) { paginator }
      described_class.records(golf_scores: :all)
    end
  end

  describe '#resumption_token' do
    it 'returns the current resumption_token' do
      allow(described_class).to receive(:response) { double(:response, resumption_token: '123456') }
      expect(described_class.resumption_token).to eq '123456'
    end

    it 'returns nil when response is nil' do
      allow(described_class).to receive(:response) { nil }
      expect(described_class.resumption_token).to be_nil
    end
  end

  describe '#initialize' do
    let(:xml) { '<record><title>Hi</title></record>' }

    it 'initializes a record from XML' do
      record = described_class.new(xml)
      expect(record.original_xml).to eq xml
    end

    it 'gets the XML from the OAI record' do
      element = double(:element, to_s: xml)
      allow(oai_record).to receive(:element) { element }
      record = described_class.new(oai_record)
      expect(record.original_xml).to eq xml
    end
  end

  describe '#document' do
    let(:xml) { '<record><title>Hi</title></record>' }
    let(:record) { described_class.new(xml) }
    let(:document) { double(:document).as_null_object }

    it 'should parse the xml with Nokogiri' do
      expect(Nokogiri::XML).to receive(:parse).with(xml) { document }
      expect(record.document).to eq document
    end
  end

  describe '#raw_data' do
    let(:oai_record) { double(:oai_record, element: '<record><id>1</id></record>') }

    it 'returns the raw xml' do
      record = described_class.new(oai_record)
      expect(record.raw_data).to eq "<?xml version=\"1.0\"?>\n<record>\n  <id>1</id>\n</record>\n"
    end
  end

  describe '#deletable?' do
    it 'returns true when header has deleted attribute' do
      allow(record).to receive(:document) { Nokogiri.parse('<?xml version="1.0"?><record><header status="deleted"></header></record>') }
      expect(record.deletable?).to be_truthy
    end

    it 'returns false when header does not have deleted attribute' do
      allow(record).to receive(:document) { Nokogiri.parse('<?xml version="1.0"?><record><header></header></record>') }
      expect(record.deletable?).to be_falsey
    end

    it 'is not deleteable if there are no deletion rules' do
      allow(described_class).to receive(:deletion_rules) { nil }
      expect(record.deletable?).to be_falsey
    end

    it 'is deletable if the block evals to true' do
      allow(described_class).to receive(:deletion_rules) { proc { true } }
      expect(record.deletable?).to be_truthy
    end

    it 'is not deletable if the block evals to true' do
      described_class.delete_if { false }
      expect(record.deletable?).to be_falsey
    end
  end
end
