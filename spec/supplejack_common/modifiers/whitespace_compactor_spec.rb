# frozen_string_literal: true

require 'spec_helper'

describe SupplejackCommon::Modifiers::WhitespaceCompactor do
  subject { described_class.new(' cats ') }

  describe '#initialize' do
    it 'assigns the original_value' do
      subject.original_value.should eq [' cats ']
    end
  end

  describe '#modify' do
    let(:node) { mock(:node) }

    it 'returns a compacted array of values' do
      subject.stub(:original_value) { ['Dogs   Hotels  - foo', 'Job   blah'] }
      subject.modify.should eq ['Dogs Hotels - foo', 'Job blah']
    end

    it 'returns the same array when the elements are not string' do
      subject.stub(:original_value) { [node, node] }
      subject.modify.should eq [node, node]
    end
  end
end
