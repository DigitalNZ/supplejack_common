# frozen_string_literal: true

# rubocop:disable Style/Semicolon
require 'spec_helper'

describe SupplejackCommon::Enrichment do
  class TestParser
    def self._throttle
      nil
    end
  end

  let(:fragment) { mock(:fragment, priority: 0) }
  let(:block) { proc {} }
  let(:record) { mock(:record, id: 1234, attributes: {}, fragments: [fragment]) }
  subject { described_class.new(:ndha_rights, { block: block }, record, TestParser) }

  describe '#initialize' do
    it 'sets the name and block' do
      subject.name.should eq :ndha_rights
      subject.block.should eq block
    end

    it 'sets the parser class' do
      subject.parser_class.should eq TestParser
    end
  end

  describe '#url' do
    it 'should store the enrichment URL' do
      subject.url 'http://google.com'
      subject._url.should eq 'http://google.com'
    end
  end

  describe '#identifier' do
    it 'should join the parser class name and the name of the enrichment' do
      subject.identifier.should eq 'test_parser_ndha_rights'
    end
  end

  describe '#reject_if' do
    it 'adds a rejection rule' do
      subject.reject_if { 'text' }
      subject._rejection_rules[subject.identifier].should be_a Proc
    end
  end

  describe '#format' do
    it 'should store the enrichment format' do
      subject.format :xml
      subject._format.should eq :xml
    end
  end

  describe '#requires' do
    it 'should store a requirement with a name and block' do
      subject.requires :thumbnail_url do
        'Hi'
      end

      subject._required_attributes.should include(thumbnail_url: 'Hi')
    end

    it 'rescues from any exception in the block' do
      subject.requires :thumbnail_url do
        raise StandardError, 'Error!!'
      end

      subject._required_attributes.should include(thumbnail_url: nil)
    end
  end

  describe '#namespaces' do
    it 'stores the namespaces for the resource' do
      subject.namespaces dc: 'http://purl.org/dc/elements/1.1/', xsi: 'http://www.w3.org/2001/XMLSchema-instance'
      subject._namespaces.should eq(dc: 'http://purl.org/dc/elements/1.1/', xsi: 'http://www.w3.org/2001/XMLSchema-instance')
    end
  end

  describe '#attribute' do
    it 'stores the attribute definitions' do
      subject.attribute :dc_rights, xpath: '//dc:identifier'
      subject._attribute_definitions.should include(dc_rights: { xpath: '//dc:identifier' })
    end
  end

  describe '#evaluate_block' do
    it 'should evaluate the block' do
      enrichment = described_class.new(:rights, { block: proc { url 'http://google.com' } }, record, TestParser)
      enrichment._url.should eq 'http://google.com'
    end

    it 'should evaluate the get and then the URL' do
      enrichment = described_class.new(:rights, { block: proc { url "http://google.com/#{record.dc_identifier}" } }, mock(:record, id: 1234, dc_identifier: '1.jpg'), TestParser)
      enrichment._url.should eq 'http://google.com/1.jpg'
    end
  end

  describe '#resource' do
    let!(:enrichment) { described_class.new(:ndha_rights, { block: proc { url 'http://goo.gle/1'; format 'xml' } }, record, TestParser) }

    before do
      record.stub(:class) { mock(:class, _throttle: {}) }
      TestParser.stub(:_request_timeout) { nil }
    end

    it 'should store the attributes from the enrichment' do
      enrichment.attributes[:title] = 'Title'
      enrichment.resource.attributes[:title].should eq 'Title'
    end

    it 'should initialize a xml resource object' do
      SupplejackCommon::XmlResource.should_receive(:new).with('http://goo.gle/1', attributes: { priority: 1, source_id: 'ndha_rights' })
      enrichment.resource
    end

    it 'should initialize a json resource object' do
      enrichment = described_class.new(:ndha_rights, { block: proc { url 'http://goo.gle/1'; format 'json' } }, record, TestParser)
      SupplejackCommon::JsonResource.should_receive(:new).with('http://goo.gle/1', attributes: { priority: 1, source_id: 'ndha_rights' })
      enrichment.resource
    end

    it 'should initialize a file resource object' do
      enrichment = described_class.new(:ndha_rights, { block: proc { url 'http://goo.gle/1'; format 'file' } }, record, TestParser)
      SupplejackCommon::FileResource.should_receive(:new).with('http://goo.gle/1', attributes: { priority: 1, source_id: 'ndha_rights' })
      enrichment.resource
    end

    it 'should return a resource object' do
      enrichment.resource.should be_a SupplejackCommon::Resource
    end

    it 'initializes the resource with throttle options' do
      TestParser.stub(:_throttle) { { host: 'gdata.youtube.com', delay: 1 } }
      SupplejackCommon::Resource.should_receive(:new).with('http://goo.gle/1', attributes: { priority: 1, source_id: 'ndha_rights' }, throttling_options: { host: 'gdata.youtube.com', delay: 1 })
      enrichment.resource
    end

    it 'initalizes the resource with request timeout options' do
      TestParser.stub(:_request_timeout) { 100 }
      SupplejackCommon::Resource.should_receive(:new).with(anything, hash_including(request_timeout: 100))
      enrichment.resource
    end
  end

  describe '#primary' do
    it 'returns a wrapped fragment' do
      subject.primary.fragment.should eq fragment
    end

    it 'should initialize a FragmentWrap object' do
      subject.primary.should be_a SupplejackCommon::FragmentWrap
    end
  end

  describe '#enrichable?' do
    context 'required attributes' do
      it 'returns true when all required fields are present' do
        subject._required_attributes = { thumbnail_url: 'http://google.com/1', title: 'Hi' }
        subject.enrichable?.should be_true
      end

      it 'handles boolean values correctly' do
        subject._required_attributes = { is_catalog_record: false }
        subject.enrichable?.should be_true
      end

      it 'returns false when a required field is not present' do
        subject._required_attributes = { thumbnail_url: nil, title: 'Hi' }
        subject.enrichable?.should be_false
      end
    end

    context 'rejection block' do
      it 'returns false if the rejection block evaluates to true' do
        subject.reject_if { true }
        subject.enrichable?.should be_false
      end

      it 'returns true if the rejection block evaluates to false' do
        subject.reject_if { false }
        subject.enrichable?.should be_true
      end
    end
  end

  describe '#requirements' do
    it 'returns the value of the requirement block' do
      subject.requires :tap_id do
        12_345
      end

      subject.requirements[:tap_id].should eq 12_345
    end
  end

  describe '#http_headers' do
    it 'returns the value of the http_headers' do
      subject.http_headers('Authorization': 'hello')
      subject._http_headers.should eq('Authorization': 'hello')
    end
  end
end
# rubocop:enable Style/Semicolon
