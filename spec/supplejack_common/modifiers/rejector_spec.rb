# frozen_string_literal: true

require 'spec_helper'

describe SupplejackCommon::Modifiers::WhitespaceCompactor do
  subject { described_class.new(%w[cats bats]) }

  describe '#initialize' do
    it 'assigns the original_value' do
      expect(subject.original_value).to eq %w[cats bats]
    end
  end

  describe '#modify' do
    let(:node) { double(:node) }

    it 'returns a compacted array of values' do
      allow(subject).to receive(:original_value) { ['Dogs   Hotels  - foo', 'Job   blah'] }
      expect(subject.modify).to eq ['Dogs Hotels - foo', 'Job blah']
    end

    it 'returns the same array when the elements are not string' do
      allow(subject).to receive(:original_value) { [node, node] }
      expect(subject.modify).to eq [node, node]
    end
  end
end
