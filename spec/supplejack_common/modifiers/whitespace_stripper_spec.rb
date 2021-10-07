# frozen_string_literal: true

require 'spec_helper'

describe SupplejackCommon::Modifiers::WhitespaceStripper do
  subject { described_class.new(' cats ') }

  describe '#initialize' do
    it 'assigns the original_value' do
      subject.original_value.should eq [' cats ']
    end
  end

  describe '#modify' do
    let(:node) { mock(:node) }

    it 'returns a stripped array of values' do
      subject.stub(:original_value) { [' Dogs ', ' cats '] }
      subject.modify.should eq %w[Dogs cats]
    end

    it 'returns the same array when the elements are not string' do
      subject.stub(:original_value) { [node, node] }
      subject.modify.should eq [node, node]
    end
  end
end
