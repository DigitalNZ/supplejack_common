# frozen_string_literal: true

require 'spec_helper'

describe SupplejackCommon::XmlResource do
  subject { described_class.new('http://google.com/1', namespaces: { dc: 'http://purl.org/dc/elements/1.1/' }) }

  describe '#initialize' do
    it 'should set the namespaces class attribute' do
      expect(subject.class._namespaces[:dc]).to eq 'http://purl.org/dc/elements/1.1/'
    end
  end

  describe '#document' do
    it 'should parse the resource as XML' do
      allow(subject).to receive(:fetch_document) { '</xml>' }
      expect(subject.document).to be_a Nokogiri::XML::Document
    end
  end

  describe '#strategy_value' do
    let(:doc) { double(:document) }

    it 'should create a new XpathOption with the namespaces class attribute' do
      allow(subject).to receive(:document) { doc }
      expect(SupplejackCommon::XpathOption).to receive(:new).with(doc, { xpath: '/doc' }, dc: 'http://purl.org/dc/elements/1.1/') { double(:option).as_null_object }
      subject.strategy_value(xpath: '/doc')
    end
  end
end
