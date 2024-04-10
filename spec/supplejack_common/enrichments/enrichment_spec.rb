# frozen_string_literal: true

# rubocop:disable Style/Semicolon
require 'spec_helper'

describe SupplejackCommon::Enrichment do
  class TestParser
    def self._throttle
      nil
    end
  end

  let(:fragment) { double(:fragment, priority: 0) }
  let(:block) { proc {} }
  let(:record) { double(:record, id: 1234, attributes: {}, fragments: [fragment]) }
  subject { described_class.new(:ndha_rights, { block: block }, record, TestParser) }

  describe '#initialize' do
    it 'sets the name and block' do
      expect(subject.name).to eq :ndha_rights
      expect(subject.block).to eq block
    end

    it 'sets the parser class' do
      expect(subject.parser_class).to eq TestParser
    end
  end

  describe '#url' do
    it 'should store the enrichment URL' do
      subject.url 'http://google.com'
      expect(subject._url).to eq 'http://google.com'
    end
  end

  describe '#identifier' do
    it 'should join the parser class name and the name of the enrichment' do
      expect(subject.identifier).to eq 'test_parser_ndha_rights'
    end
  end

  describe '#reject_if' do
    it 'adds a rejection rule' do
      subject.reject_if { 'text' }
      expect(subject._rejection_rules[subject.identifier]).to be_a Proc
    end
  end

  describe '#format' do
    it 'should store the enrichment format' do
      subject.format :xml
      expect(subject._format).to eq :xml
    end
  end

  describe '#requires' do
    it 'should store a requirement with a name and block' do
      subject.requires :thumbnail_url do
        'Hi'
      end

      expect(subject._required_attributes).to include(thumbnail_url: 'Hi')
    end

    it 'rescues from any exception in the block' do
      subject.requires :thumbnail_url do
        raise StandardError, 'Error!!'
      end

      expect(subject._required_attributes).to include(thumbnail_url: nil)
    end
  end

  describe '#namespaces' do
    it 'stores the namespaces for the resource' do
      subject.namespaces dc: 'http://purl.org/dc/elements/1.1/', xsi: 'http://www.w3.org/2001/XMLSchema-instance'
      expect(subject._namespaces).to eq(dc: 'http://purl.org/dc/elements/1.1/', xsi: 'http://www.w3.org/2001/XMLSchema-instance')
    end
  end

  describe '#attribute' do
    it 'stores the attribute definitions' do
      subject.attribute :dc_rights, xpath: '//dc:identifier'
      expect(subject._attribute_definitions).to include(dc_rights: { xpath: '//dc:identifier' })
    end
  end

  describe '#evaluate_block' do
    it 'should evaluate the block' do
      enrichment = described_class.new(:rights, { block: proc { url 'http://google.com' } }, record, TestParser)
      expect(enrichment._url).to eq 'http://google.com'
    end

    it 'should evaluate the get and then the URL' do
      enrichment = described_class.new(:rights, { block: proc { url "http://google.com/#{record.dc_identifier}" } }, double(:record, id: 1234, dc_identifier: '1.jpg'), TestParser)
      expect(enrichment._url).to eq 'http://google.com/1.jpg'
    end
  end

  describe '#resource' do
    let!(:enrichment) { described_class.new(:ndha_rights, { block: proc { url 'http://goo.gle/1'; format 'xml' } }, record, TestParser) }

    before do
      allow(record).to receive(:class) { double(:class, _throttle: {}) }
      allow(TestParser).to receive(:_request_timeout) { nil }
    end

    it 'should store the attributes from the enrichment' do
      enrichment.attributes[:title] = 'Title'
      expect(enrichment.resource.attributes[:title]).to eq 'Title'
    end

    it 'should initialize a xml resource object' do
      expect(SupplejackCommon::XmlResource).to receive(:new).with('http://goo.gle/1', { attributes: { priority: 1, source_id: 'ndha_rights' } })
      enrichment.resource
    end

    it 'should initialize a json resource object' do
      enrichment = described_class.new(:ndha_rights, { block: proc { url 'http://goo.gle/1'; format 'json' } }, record, TestParser)
      expect(SupplejackCommon::JsonResource).to receive(:new).with('http://goo.gle/1', { attributes: { priority: 1, source_id: 'ndha_rights' } })
      enrichment.resource
    end

    it 'should initialize a file resource object' do
      enrichment = described_class.new(:ndha_rights, { block: proc { url 'http://goo.gle/1'; format 'file' } }, record, TestParser)
      expect(SupplejackCommon::FileResource).to receive(:new).with('http://goo.gle/1', { attributes: { priority: 1, source_id: 'ndha_rights' } })
      enrichment.resource
    end

    it 'should return a resource object' do
      expect(enrichment.resource).to be_a SupplejackCommon::Resource
    end

    it 'initializes the resource with throttle options' do
      allow(TestParser).to receive(:_throttle) { { host: 'gdata.youtube.com', delay: 1 } }
      expect(SupplejackCommon::Resource).to receive(:new).with('http://goo.gle/1', { attributes: { priority: 1, source_id: 'ndha_rights' }, throttling_options: { host: 'gdata.youtube.com', delay: 1 } })
      enrichment.resource
    end

    it 'initalizes the resource with request timeout options' do
      allow(TestParser).to receive(:_request_timeout) { 100 }
      expect(SupplejackCommon::Resource).to receive(:new).with(anything, hash_including(request_timeout: 100))
      enrichment.resource
    end
  end

  describe '#primary' do
    it 'returns a wrapped fragment' do
      expect(subject.primary.fragment).to eq fragment
    end

    it 'should initialize a FragmentWrap object' do
      expect(subject.primary).to be_a SupplejackCommon::FragmentWrap
    end
  end

  describe '#enrichable?' do
    context 'required attributes' do
      it 'returns true when all required fields are present' do
        subject._required_attributes = { thumbnail_url: 'http://google.com/1', title: 'Hi' }
        expect(subject.enrichable?).to be_truthy
      end

      it 'handles boolean values correctly' do
        subject._required_attributes = { is_catalog_record: false }
        expect(subject.enrichable?).to be_truthy
      end

      it 'returns false when a required field is not present' do
        subject._required_attributes = { thumbnail_url: nil, title: 'Hi' }
        expect(subject.enrichable?).to be_falsey
      end
    end

    context 'rejection block' do
      it 'returns false if the rejection block evaluates to true' do
        subject.reject_if { true }
        expect(subject.enrichable?).to be_falsey
      end

      it 'returns true if the rejection block evaluates to false' do
        subject.reject_if { false }
        expect(subject.enrichable?).to be_truthy
      end
    end
  end

  describe '#requirements' do
    it 'returns the value of the requirement block' do
      subject.requires :tap_id do
        12_345
      end

      expect(subject.requirements[:tap_id]).to eq 12_345
    end
  end

  describe '#http_headers' do
    it 'returns the value of the http_headers' do
      subject.http_headers('Authorization': 'hello')
      expect(subject._http_headers).to eq('Authorization': 'hello')
    end
  end
end
# rubocop:enable Style/Semicolon
