# frozen_string_literal: true

require 'spec_helper'

describe SupplejackCommon::Modifiers::Truncator do
  describe '#initialize' do
    it 'assigns the original value and the length' do
      truncator = described_class.new(['Value'], 300)
      truncator.original_value.should eq ['Value']
      truncator.length.should eq 300
    end
  end

  describe 'modify' do
    it 'truncates the text to 30 charachters' do
      truncator = described_class.new(['A string longer than 30 charachters'], 30, '')
      truncator.modify.should eq ['A string longer than 30 charac']
    end

    it 'adds a ommission at the end' do
      truncator = described_class.new(['A string longer than 30 charachters'], 30, '...')
      truncator.modify.should eq ['A string longer than 30 cha...']
    end
  end
end
