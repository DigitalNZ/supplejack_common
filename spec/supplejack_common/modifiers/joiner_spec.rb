# frozen_string_literal: true

require 'spec_helper'

describe SupplejackCommon::Modifiers::Joiner do
  let(:klass) { SupplejackCommon::Modifiers::Joiner }
  let(:join) { klass.new(%w[cats dogs], ',') }

  describe '#initialize' do
    it 'assigns the original_value and a separator' do
      join.original_value.should eq %w[cats dogs]
      join.joiner.should eq ','
    end
  end

  describe 'value' do
    it 'joins the multiple elements into one' do
      join.modify.should eq ['cats,dogs']
    end
  end
end
