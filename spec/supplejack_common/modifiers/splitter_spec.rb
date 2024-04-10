# frozen_string_literal: true

require 'spec_helper'

describe SupplejackCommon::Modifiers::Splitter do
  describe '#initialize' do
    it 'assigns the original value and the split_value' do
      splitter = described_class.new(['Value'], /\s/)

      expect(splitter.original_value).to eq ['Value']
      expect(splitter.split_value).to eq(/\s/)
    end
  end

  describe 'modify' do
    it 'splits the value based on a string' do
      splitter = described_class.new(['A couple :: of values:: separated'], '::')

      expect(splitter.modify).to eq ['A couple ', ' of values', ' separated']
    end

    it 'splits the value based on a regular expression' do
      splitter = described_class.new(['Split on vowels'], /[aeiou]/)

      expect(splitter.modify).to eq ['Spl', 't ', 'n v', 'w', 'ls']
    end
  end
end
