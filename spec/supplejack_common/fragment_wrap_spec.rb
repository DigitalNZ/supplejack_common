# frozen_string_literal: true

require 'spec_helper'

describe SupplejackCommon::FragmentWrap do
  let(:fragment) { double(:fragment, attributes: { 'title' => 'Hi' }) }
  let(:wrap) { SupplejackCommon::FragmentWrap.new(fragment) }

  describe '#[]' do
    it 'should return the specified attribute' do
      expect(wrap[:title].to_a).to eq ['Hi']
    end

    it 'should return a AttributeValue object' do
      expect(wrap[:title]).to be_a SupplejackCommon::AttributeValue
    end
  end
end
