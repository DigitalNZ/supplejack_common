# frozen_string_literal: true

require 'spec_helper'

describe SupplejackCommon::Oai::Base do
  let(:header) { mock(:header, identifier: '123') }
  let(:root) { mock(:root).as_null_object }
  let(:oai_record) { mock(:oai_record, header: header, metadata: [root]).as_null_object }
  let(:record) { described_class.new(oai_record) }

  before do
    described_class._base_urls[described_class.identifier] = []
    described_class._attribute_definitions[described_class.identifier] = {}
    described_class.clear_definitions
  end

  describe '.client' do
    it 'initializes a new OAI client' do
      described_class.base_url 'http://google.com'
      OAI::Client.should_receive(:new).with('http://google.com', {}, nil)
      described_class.client
    end
  end

  describe '#metadata_prefix' do
    it 'gets the metadata prefix' do
      described_class.metadata_prefix 'prefix'
      described_class.get_metadata_prefix.should eq 'prefix'
    end
  end

  describe '#set' do
    it 'gets the set name' do
      described_class.set 'name'
      described_class.get_set.should eq 'name'
    end
  end

  describe '.records' do
    let(:client) { mock(:client) }
    let!(:paginator) { mock(:paginator) }

    before(:each) do
      described_class.stub(:client) { client }
    end

    it 'initializes a PaginatedCollection with the results' do
      SupplejackCommon::Oai::PaginatedCollection.should_receive(:new).with(client, {}, described_class) { paginator }
      described_class.records
    end

    it 'accepts a :from option and pass it on to list_records' do
      date = Date.today
      SupplejackCommon::Oai::PaginatedCollection.should_receive(:new).with(client, { from: date }, described_class) { paginator }
      described_class.records(from: date)
    end

    it 'accepts a :limit option' do
      SupplejackCommon::Oai::PaginatedCollection.should_receive(:new).with(client, { limit: 10 }, described_class) { paginator }
      described_class.records(limit: 10)
    end

    it 'add the :metadata_prefix option from the DSL' do
      SupplejackCommon::Oai::PaginatedCollection.should_receive(:new).with(client, { metadata_prefix: 'prefix' }, described_class) { paginator }

      described_class.metadata_prefix 'prefix'
      described_class.records
    end

    it 'add the :set option from the DSL' do
      SupplejackCommon::Oai::PaginatedCollection.should_receive(:new).with(client, { set: 'name' }, described_class) { paginator }

      described_class.set 'name'
      described_class.records
    end

    it 'does not pass on unknown options' do
      SupplejackCommon::Oai::PaginatedCollection.should_not_receive(:new).with(client, { golf_scores: :all }, described_class) { paginator }
      described_class.records(golf_scores: :all)
    end
  end

  describe '#resumption_token' do
    it 'returns the current resumption_token' do
      described_class.stub(:response) { mock(:response, resumption_token: '123456') }
      described_class.resumption_token.should eq '123456'
    end

    it 'returns nil when response is nil' do
      described_class.stub(:response) { nil }
      described_class.resumption_token.should be_nil
    end
  end

  describe '#initialize' do
    let(:xml) { '<record><title>Hi</title></record>' }

    it 'initializes a record from XML' do
      record = described_class.new(xml)
      record.original_xml.should eq xml
    end

    it 'gets the XML from the OAI record' do
      element = mock(:element, to_s: xml)
      oai_record.stub(:element) { element }
      record = described_class.new(oai_record)
      record.original_xml.should eq xml
    end
  end

  describe '#document' do
    let(:xml) { '<record><title>Hi</title></record>' }
    let(:record) { described_class.new(xml) }
    let(:document) { mock(:document).as_null_object }

    it 'should parse the xml with Nokogiri' do
      Nokogiri::XML.should_receive(:parse).with(xml) { document }
      record.document.should eq document
    end
  end

  describe '#raw_data' do
    let(:oai_record) { mock(:oai_record, element: '<record><id>1</id></record>') }

    it 'returns the raw xml' do
      record = described_class.new(oai_record)
      record.raw_data.should eq "<?xml version=\"1.0\"?>\n<record>\n  <id>1</id>\n</record>\n"
    end
  end

  describe '#deletable?' do
    it 'returns true when header has deleted attribute' do
      record.stub(:document) { Nokogiri.parse('<?xml version="1.0"?><record><header status="deleted"></header></record>') }
      record.deletable?.should be_true
    end

    it 'returns false when header does not have deleted attribute' do
      record.stub(:document) { Nokogiri.parse('<?xml version="1.0"?><record><header></header></record>') }
      record.deletable?.should be_false
    end

    it 'is not deleteable if there are no deletion rules' do
      described_class.stub(:deletion_rules) { nil }
      record.deletable?.should be_false
    end
    
    it 'is deletable if the block evals to true' do
      described_class.delete_if { true }
      record.deletable?.should be_true
    end

    it 'is not deletable if the block evals to true' do
      described_class.delete_if { false }
      record.deletable?.should be_false
    end
  end
end
