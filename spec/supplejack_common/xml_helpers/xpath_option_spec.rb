# frozen_string_literal: true

require 'spec_helper'

describe SupplejackCommon::XpathOption do
  subject { described_class.new(document, options) }

  let(:document) { Nokogiri.parse('<?xml version="1.0" ?><items><item><title>Hi</title></item></items>') }
  let(:options) { { xpath: 'table/tr' } }

  describe '#value' do
    let(:nodes) { double(:nodes, text: 'Value') }

    before { allow(subject).to receive(:nodes) { nodes } }

    it 'returns the sanitized html from the nodes' do
      expect(subject.value).to eq 'Value'
    end

    it 'returns the sanitized html from an array of NodeSets' do
      allow(subject).to receive(:nodes) { [double(:node_set, text: 'Value')] }
      expect(subject.value).to eq ['Value']
    end

    it 'returns the node object' do
      allow(subject).to receive(:options).and_return({ xpath: 'table/tr', object: true })
      expect(subject.value).to eq nodes
    end

    context 'custom sanitization settings' do
      let(:nodes) { double(:nodes, to_html: '<br>Value<br>') }

      before do
        allow(subject).to receive(:nodes) { nodes }
        allow(subject).to receive(:options).and_return({ sanitize_config: { elements: ['br'] } })
      end

      it 'lets you specify what elements not to sanitize' do
        expect(subject.value).to eq('<br>Value<br>')
      end

      it 'does not encode special entities' do
        node = double(:nodes, to_html: '<br>Test & Test<br>')
        allow(subject).to receive(:nodes) { node }

        expect(subject.value).to eq('<br>Test & Test<br>')
      end
    end
  end

  describe '#xpath_value' do
    it 'appends a dot when document is a NodeSet' do
      allow(subject).to receive(:document) { document.xpath('//items/item') }
      expect(subject.send(:xpath_value, '//title')).to eq './/title'
    end

    it 'appends a dot when document is a Element' do
      allow(subject).to receive(:document) { document.xpath('//items/item').first }
      expect(subject.send(:xpath_value, '//title')).to eq './/title'
    end

    it 'returns the same xpath for a full document' do
      allow(subject).to receive(:document) { document }
      expect(subject.send(:xpath_value, '//title')).to eq '//title'
    end
  end

  describe '#initialize' do
    it 'assigns the document and options' do
      expect(subject.document).to eq document
      expect(subject.options).to eq options
    end
  end

  describe '#nodes' do
    let(:node) { double(:node) }

    it 'finds the nodes specified by the xpath string' do
      expect(document).to receive(:xpath).with('table/tr', {}).and_return([node])
      expect(subject.send(:nodes)).to eq [node]
    end

    it 'returns all matching nodes for the multiple xpath expressions' do
      allow(subject).to receive(:options).and_return({ xpath: ['//table/tr', '//div/img'] })
      expect(document).to receive(:xpath).with('//table/tr', {}).and_return([node])
      expect(document).to receive(:xpath).with('//div/img', {}).and_return([node])
      expect(subject.send(:nodes)).to eq [node, node]
    end

    it 'returns a empty array when xpath is not defined' do
      allow(subject).to receive(:options).and_return({ xpath: '' })
      expect(subject.send(:nodes)).to eq []
    end

    it 'adds all namespaces to the xpath query' do
      xo = described_class.new(document, { xpath: '//dc:id' }, { dc: 'http://goo.gle/', xsi: 'http://yah.oo' })
      expect(document).to receive(:xpath).with('//dc:id',
                                               { dc: 'http://goo.gle/', xsi: 'http://yah.oo' }).and_return([node])

      expect(xo.send(:nodes)).to eq [node]
    end
  end
end
