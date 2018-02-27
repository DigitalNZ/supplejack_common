# frozen_string_literal: true

require 'spec_helper'

describe SupplejackCommon::Modifiers::AbstractModifier do
  let(:klass) { SupplejackCommon::Modifiers::AbstractModifier }
  let(:original_value) { ['Old Value'] }
  let(:modifier) { klass.new(original_value) }

  it 'initializes the original value' do
    modifier.original_value.should eq original_value
  end

  describe '#value' do
    it 'initializes a new AttributeValue object' do
      modifier.stub(:modify) { 'New Value' }
      SupplejackCommon::AttributeValue.should_receive(:new).with('New Value') { mock(:attr_value) }
      modifier.value
    end
  end
end
