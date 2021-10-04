# frozen_string_literal: true

require 'spec_helper'

describe SupplejackCommon::Modifiers::Adder do
  let(:original_value) { ['Images'] }
  let(:replacer) { described_class.new(original_value, 'Videos') }

  describe 'modify' do
    it 'adds a value to the original value' do
      replacer.modify.should eq %w[Images Videos]
    end

    it 'adds an array of values to the original_value' do
      replacer.stub(:new_value) { %w[Videos Audio] }
      replacer.modify.should eq %w[Images Videos Audio]
    end
  end
end
