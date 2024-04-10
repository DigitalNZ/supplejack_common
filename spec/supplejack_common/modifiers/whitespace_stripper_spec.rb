# frozen_string_literal: true

require 'spec_helper'

describe SupplejackCommon::Modifiers::WhitespaceStripper do
  subject { described_class.new(' cats ') }

  describe '#initialize' do
    it 'assigns the original_value' do
      expect(subject.original_value).to eq [' cats ']
    end
  end

  describe '#modify' do
    let(:node) { double(:node) }

    it 'returns a stripped array of values' do
      allow(subject).to receive(:original_value).and_return([' Dogs ', ' cats '])
      expect(subject.modify).to eq %w[Dogs cats]
    end

    it 'returns the same array when the elements are not string' do
      allow(subject).to receive(:original_value) { [node, node] }
      expect(subject.modify).to eq [node, node]
    end
  end
end
