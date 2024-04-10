# frozen_string_literal: true

require 'spec_helper'

describe SupplejackCommon::Modifiers::Joiner do
  subject { described_class.new(%w[cats dogs], ',') }

  describe '#initialize' do
    it 'assigns the original_value and a separator' do
      expect(subject.original_value).to eq %w[cats dogs]
      expect(subject.joiner).to eq ','
    end
  end

  describe 'value' do
    it 'joins the multiple elements into one' do
      expect(subject.modify).to eq ['cats,dogs']
    end
  end
end
