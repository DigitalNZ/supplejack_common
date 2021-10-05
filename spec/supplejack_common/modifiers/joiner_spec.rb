# frozen_string_literal: true

require 'spec_helper'

describe SupplejackCommon::Modifiers::Joiner do
  subject { described_class.new(%w[cats dogs], ',') }

  describe '#initialize' do
    it 'assigns the original_value and a separator' do
      subject.original_value.should eq %w[cats dogs]
      subject.joiner.should eq ','
    end
  end

  describe 'value' do
    it 'joins the multiple elements into one' do
      subject.modify.should eq ['cats,dogs']
    end
  end
end
