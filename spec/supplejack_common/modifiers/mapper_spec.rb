# frozen_string_literal: true

require 'spec_helper'

describe SupplejackCommon::Modifiers::Mapper do
  let(:original_value) { ['http://google.com?width=100&height=200'] }
  subject { described_class.new(original_value, /width=[\d]{1,4}/ => 'width=520') }

  it 'initializes the original value' do
    subject.original_value.should eq original_value
  end

  it 'initializes the replacement_rules' do
    subject.replacement_rules.should eq(/width=[\d]{1,4}/ => 'width=520')
  end

  describe 'modify' do
    it 'modifies the value' do
      subject.modify.should eq ['http://google.com?width=520&height=200']
    end

    it 'makes multiple modifications' do
      subject.stub(:replacement_rules) { { /width=[\d]{1,4}/ => 'width=520', /height=[\d]{1,4}/ => 'height=310' } }
      subject.modify.should eq ['http://google.com?width=520&height=310']
    end

    it 'returns the original value when it does not match any rule' do
      subject.stub(:replacement_rules) { { /microsoft=[\d]/ => 'anything' } }
      subject.modify.should eq original_value
    end
  end
end
