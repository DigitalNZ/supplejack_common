# frozen_string_literal: true

require 'spec_helper'

describe SupplejackCommon::FragmentWrap do
  let(:fragment) { double(:fragment, attributes: { 'title' => 'Hi' }) }
  let(:wrap) { described_class.new(fragment) }

  describe '#[]' do
    it 'returns the specified attribute' do
      expect(wrap[:title].to_a).to eq ['Hi']
    end

    it 'returns a AttributeValue object' do
      expect(wrap[:title]).to be_a SupplejackCommon::AttributeValue
    end
  end
end
