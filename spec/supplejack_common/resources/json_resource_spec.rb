# frozen_string_literal: true

require 'spec_helper'

describe SupplejackCommon::JsonResource do
  subject { described_class.new('http://google.com/1', {}) }

  describe '#document' do
    it 'should parse the resource as JSON' do
      allow(subject).to receive(:fetch_document) { { title: 'Value' }.to_json }
      expect(subject.document).to eq('title' => 'Value')
    end
  end

  describe '#fetch' do
    it 'returns the value object' do
      allow(subject).to receive(:fetch_document) { { title: 'Lorem' }.to_json }
      value = subject.fetch('title')
      expect(value).to be_a SupplejackCommon::AttributeValue
      expect(value.to_a).to eq ['Lorem']
    end
  end

  describe '#requirements' do
    let(:json_resource) { described_class.new('http://google.com/1', attributes: { requirements: { required_attr: 'Lorem' } }) }

    it "returns 'requires' value" do
      expect(json_resource.requirements).to include(required_attr: 'Lorem')
    end
  end
end
