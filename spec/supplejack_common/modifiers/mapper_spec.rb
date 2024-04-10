# frozen_string_literal: true

require 'spec_helper'

describe SupplejackCommon::Modifiers::Mapper do
  let(:original_value) { ['http://google.com?width=100&height=200'] }
  subject { described_class.new(original_value, /width=[\d]{1,4}/ => 'width=520') }

  it 'initializes the original value' do
    expect(subject.original_value).to eq original_value
  end

  it 'initializes the replacement_rules' do
    expect(subject.replacement_rules).to eq(/width=[\d]{1,4}/ => 'width=520')
  end

  describe 'modify' do
    it 'modifies the value' do
      expect(subject.modify).to eq ['http://google.com?width=520&height=200']
    end

    it 'makes multiple modifications' do
      allow(subject).to receive(:replacement_rules) {
                          { /width=[\d]{1,4}/ => 'width=520', /height=[\d]{1,4}/ => 'height=310' }
                        }
      expect(subject.modify).to eq ['http://google.com?width=520&height=310']
    end

    it 'returns the original value when it does not match any rule' do
      allow(subject).to receive(:replacement_rules) { { /microsoft=[\d]/ => 'anything' } }
      expect(subject.modify).to eq original_value
    end
  end
end
