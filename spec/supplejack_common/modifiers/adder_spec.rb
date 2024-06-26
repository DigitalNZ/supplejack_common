# frozen_string_literal: true

require 'spec_helper'

describe SupplejackCommon::Modifiers::Adder do
  let(:original_value) { ['Images'] }
  let(:replacer) { described_class.new(original_value, 'Videos') }

  describe 'modify' do
    it 'adds a value to the original value' do
      expect(replacer.modify).to eq %w[Images Videos]
    end

    it 'adds an array of values to the original_value' do
      allow(replacer).to receive(:new_value).and_return(%w[Videos Audio])
      expect(replacer.modify).to eq %w[Images Videos Audio]
    end
  end
end
