# frozen_string_literal: true

require 'spec_helper'

describe SupplejackCommon::XpathOption do
  let(:document) { Nokogiri.parse('<?xml version="1.0" ?><items><item><title>Hi</title></item></items>') }
  let(:options) { { xpath: 'table/tr' } }
  subject { described_class.new(document, options) }

  describe '#value' do
    let(:nodes) { mock(:nodes, text: 'Value') }
    before { subject.stub(:nodes) { nodes } }

    it 'returns the sanitized html from the nodes' do
      subject.value.should eq 'Value'
    end

    it 'returns the sanitized html from an array of NodeSets' do
      subject.stub(:nodes) { [mock(:node_set, text: 'Value')] }
      subject.value.should eq ['Value']
    end

    it 'returns the node object' do
      subject.stub(:options) { { xpath: 'table/tr', object: true } }
      subject.value.should eq nodes
    end

    context 'custom sanitization settings' do
      let(:nodes) { mock(:nodes, to_html: '<br>Value<br>') }
      before { subject.stub(:nodes) { nodes } }

      before do
        subject.stub(:options) { { sanitize_config: { elements: ['br'] } } }
      end

      it 'lets you specify what elements not to sanitize' do
        expect(subject.value).to eq('<br>Value<br>')
      end

      it 'does not encode special entities' do
        node = mock(:nodes, to_html: '<br>Test & Test<br>')
        subject.stub(:nodes) { node }

        expect(subject.value).to eq('<br>Test & Test<br>')
      end
    end
  end

  describe '#xpath_value' do
    it 'appends a dot when document is a NodeSet' do
      subject.stub(:document) { document.xpath('//items/item') }
      subject.send(:xpath_value, '//title').should eq './/title'
    end

    it 'appends a dot when document is a Element' do
      subject.stub(:document) { document.xpath('//items/item').first }
      subject.send(:xpath_value, '//title').should eq './/title'
    end

    it 'returns the same xpath for a full document' do
      subject.stub(:document) { document }
      subject.send(:xpath_value, '//title').should eq '//title'
    end
  end

  describe '#initialize' do
    it 'assigns the document and options' do
      subject.document.should eq document
      subject.options.should eq options
    end
  end

  describe '#nodes' do
    let(:node) { mock(:node) }

    it 'finds the nodes specified by the xpath string' do
      document.should_receive(:xpath).with('table/tr', {}).and_return([node])
      subject.send(:nodes).should eq [node]
    end

    it 'returns all matching nodes for the multiple xpath expressions' do
      subject.stub(:options) { { xpath: ['//table/tr', '//div/img'] } }
      document.should_receive(:xpath).with('//table/tr', {}).and_return([node])
      document.should_receive(:xpath).with('//div/img', {}).and_return([node])
      subject.send(:nodes).should eq [node, node]
    end

    it 'returns a empty array when xpath is not defined' do
      subject.stub(:options) { { xpath: '' } }
      subject.send(:nodes).should eq []
    end

    it 'should add all namespaces to the xpath query' do
      xo = described_class.new(document, { xpath: '//dc:id' }, dc: 'http://goo.gle/', xsi: 'http://yah.oo')
      document.should_receive(:xpath).with('//dc:id', dc: 'http://goo.gle/', xsi: 'http://yah.oo').and_return([node])

      xo.send(:nodes).should eq [node]
    end
  end
end
