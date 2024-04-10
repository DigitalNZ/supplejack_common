# frozen_string_literal: true

require 'spec_helper'

describe SupplejackCommon::Modifiers::RangeSelector do
  describe '#initialize' do
    it 'assigns the original value and range options' do
      selector = described_class.new('Value', :first, :last)
      expect(selector.original_value).to eq 'Value'
      expect(selector.instance_variable_get('@start_range')).to eq :first
      expect(selector.instance_variable_get('@end_range')).to eq :last
    end
  end

  describe '#start_range' do
    it 'returns 0' do
      expect(described_class.new('Value', :first).start_range).to eq 0
    end

    it 'returns -1' do
      expect(described_class.new('Value', :last).start_range).to eq -1
    end

    it 'returns 4' do
      expect(described_class.new('Value', 5).start_range).to eq 4
    end
  end

  describe '#end_range' do
    it 'returns -1' do
      expect(described_class.new('Value', :first, :last).end_range).to eq -1
    end

    it 'returns 4' do
      expect(described_class.new('Value', 1, 5).end_range).to eq 4
    end
  end

  describe '#modify' do
    let(:value) { %w[1 2 3 4] }

    it 'returns the first element' do
      expect(described_class.new(value, :first).modify).to eq ['1']
    end

    it 'returns the last element' do
      expect(described_class.new(value, :last).modify).to eq ['4']
    end

    it 'returns the first 3 elements ' do
      expect(described_class.new(value, :first, 3).modify).to eq %w[1 2 3]
    end
  end
end
