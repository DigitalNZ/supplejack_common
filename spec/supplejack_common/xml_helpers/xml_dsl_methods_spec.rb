# frozen_string_literal: true

require 'spec_helper'

describe SupplejackCommon::XmlDslMethods do
  let(:klass) { SupplejackCommon::Xml::Base }
  let(:record) { klass.new('http://google.com') }

  describe '#fetch' do
    let(:document) { Nokogiri.parse('<doc><item>1</item><item>2</item></doc>') }

    before { allow(record).to receive(:document) { document } }

    it 'should fetch a xpath result from the document' do
      expect(record.fetch('//item').to_a).to eq %w[1 2]
    end

    it 'should return a AttributeValue' do
      expect(record.fetch('//item')).to be_a SupplejackCommon::AttributeValue
    end

    it 'should be backwards compatible with xpath option' do
      expect(record.fetch(xpath: '//item').to_a).to eq %w[1 2]
    end

    it 'should fetch a value with a namespace' do
      klass.namespaces dc: 'http://purl.org/dc/elements/1.1/'
      allow(record).to receive(:document) { Nokogiri.parse('<doc><dc:item xmlns:dc="http://purl.org/dc/elements/1.1/">1</dc:item></doc>') }
      expect(record.fetch('//dc:item').to_a).to eq ['1']
    end

    it 'should fetch just the attribute value' do
      allow(record).to receive(:document) {
                         Nokogiri.parse('<head><meta name="DC.language" content="en" scheme="RFC1766"/> </head>')
                       }

      expect(record.fetch("//head/meta[@name='DC.language']/@content").to_a).to eq(['en'])
    end
  end

  describe '#node' do
    let(:document) { Nokogiri::XML::Document.new }
    let(:xml_nodes) { double(:xml_nodes) }

    before { allow(record).to receive(:document) { document } }

    it 'extracts the XML nodes from the document' do
      expect(document).to receive(:xpath).with('//locations', anything) { xml_nodes }
      expect(record.node('//locations')).to eq xml_nodes
    end

    it 'should use all the defined namespaces on the class' do
      klass.namespaces dc: 'http://purl.org/dc/elements/1.1/'
      expect(document).to receive(:xpath).with('//dc:item', hash_including(dc: 'http://purl.org/dc/elements/1.1/')) { xml_nodes }
      expect(record.node('//dc:item')).to eq xml_nodes
    end

    context 'xml document not available' do
      before { allow(record).to receive(:document) { nil } }

      it 'returns an empty attribute_value' do
        nodes = record.node('//locations')
        expect(nodes).to be_a(SupplejackCommon::AttributeValue)
        expect(nodes.to_a).to eq []
      end
    end
  end
end
