# frozen_string_literal: true

require 'spec_helper'

describe SupplejackCommon::Modifiers do
  class ModifiersTestParser < SupplejackCommon::Base
  end

  module SupplejackApi
    class Concept
    end
  end

  let(:record) { ModifiersTestParser.new }

  before(:each) do
    record.stub(:attributes) { { category: 'Images' } }
  end

  describe '#get' do
    it 'initializes a new AttributeValue with the value from the attribute' do
      record.get(:category).should be_a SupplejackCommon::AttributeValue
      record.get(:category).original_value.should eq ['Images']
    end
  end

  describe '#compose' do
    let(:thumb) { SupplejackCommon::AttributeValue.new('http://google.com/1') }
    let(:extension) { SupplejackCommon::AttributeValue.new('thumb.jpg') }

    it 'joins multiple attribute values and a string' do
      value = record.compose(thumb, '/', extension)
      value.to_a.should eq ['http://google.com/1/thumb.jpg']
    end

    it 'joins the values with a comma' do
      value = record.compose('dogs', 'cats', extension, separator: ', ')
      value.to_a.should eq ['dogs, cats, thumb.jpg']
    end
  end

  describe '#concept_lookup' do
    before do
      SupplejackApi::Concept.stub_chain(:where, :map).and_return([1, 2, 3])
    end
    it 'return concepts that has fragments with sameAs field contains lookup url' do
      values = record.concept_lookup('http://localhost.com')
      values.to_a.should eq [1, 2, 3]
    end
  end
end
