# frozen_string_literal: true

require 'spec_helper'

describe SupplejackCommon::Modifiers::RangeSelector do
  describe '#initialize' do
    it 'assigns the original value and range options' do
      selector = described_class.new('Value', :first, :last)
      selector.original_value.should eq 'Value'
      selector.instance_variable_get('@start_range').should eq :first
      selector.instance_variable_get('@end_range').should eq :last
    end
  end

  describe '#start_range' do
    it 'returns 0' do
      described_class.new('Value', :first).start_range.should eq 0
    end

    it 'returns -1' do
      described_class.new('Value', :last).start_range.should eq -1
    end

    it 'returns 4' do
      described_class.new('Value', 5).start_range.should eq 4
    end
  end

  describe '#end_range' do
    it 'returns -1' do
      described_class.new('Value', :first, :last).end_range.should eq -1
    end

    it 'returns 4' do
      described_class.new('Value', 1, 5).end_range.should eq 4
    end
  end

  describe '#modify' do
    let(:value) { %w[1 2 3 4] }

    it 'returns the first element' do
      described_class.new(value, :first).modify.should eq ['1']
    end

    it 'returns the last element' do
      described_class.new(value, :last).modify.should eq ['4']
    end

    it 'returns the first 3 elements ' do
      described_class.new(value, :first, 3).modify.should eq %w[1 2 3]
    end
  end
end
