# frozen_string_literal: true

require 'spec_helper'

describe SupplejackCommon::Modifiers::Splitter do
  let(:klass) { SupplejackCommon::Modifiers::Splitter }

  describe '#initialize' do
    it 'assigns the original value and the split_value' do
      splitter = klass.new(['Value'], /\s/)
      splitter.original_value.should eq ['Value']
      splitter.split_value.should eq(/\s/)
    end
  end

  describe 'modify' do
    it 'splits the value based on a string' do
      splitter = klass.new(['A couple :: of values:: separated'], '::')
      splitter.modify.should eq ['A couple ', ' of values', ' separated']
    end

    it 'splits the value based on a regular expression' do
      splitter = klass.new(['Split on vowels'], /[aeiou]/)
      splitter.modify.should eq ['Spl', 't ', 'n v', 'w', 'ls']
    end
  end
end
