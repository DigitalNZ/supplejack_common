# frozen_string_literal: true

require 'spec_helper'

describe SupplejackCommon::Modifiers::AbstractModifier do
  let(:original_value) { ['Old Value'] }
  let(:modifier) { described_class.new(original_value) }

  it 'initializes the original value' do
    expect(modifier.original_value).to eq original_value
  end

  describe '#value' do
    it 'initializes a new AttributeValue object' do
      allow(modifier).to receive(:modify).and_return('New Value')
      expect(SupplejackCommon::AttributeValue).to receive(:new).with('New Value') { double(:attr_value) }
      modifier.value
    end
  end
end
