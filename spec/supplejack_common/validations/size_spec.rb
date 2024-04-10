# frozen_string_literal: true

require 'spec_helper'

describe ActiveModel::Validations::SizeValidator do
  context 'validates that the attribute has a maximum number of values' do
    class TestJsonSize < SupplejackCommon::Json::Base
      attribute :landing_url, path: 'landing_url'
      validates :landing_url, size: { maximum: 2 }
    end

    it 'should be valid when it has one value' do
      record = TestJsonSize.new('landing_url' => ['http://google.com/1'])
      record.set_attribute_values
      expect(record.valid?).to be_truthy
    end

    it 'should not be valid when it has more than the maximum' do
      record = TestJsonSize.new('landing_url' => ['http://google.com/1', 'http://google.com/2', 'http://google.com/3'])
      record.set_attribute_values
      expect(record.valid?).to be_falsey
    end
  end

  context 'validates that the attribute has the exact number of values' do
    class TestJsonSize < SupplejackCommon::Json::Base
      attribute :landing_url, path: 'landing_url'
      validates :landing_url, size: { is: 1 }
    end

    it 'should be valid when it has one value' do
      record = TestJsonSize.new('landing_url' => ['http://google.com/1'])
      record.set_attribute_values
      expect(record.valid?).to be_truthy
    end

    it 'should not be valid when it has 0 values' do
      record = TestJsonSize.new('landing_url' => [])
      record.set_attribute_values
      expect(record.valid?).to be_falsey
    end

    it 'should not be valid when it has 2 values' do
      record = TestJsonSize.new('landing_url' => ['http://google.com/1', 'http://google.com/2'])
      record.set_attribute_values
      expect(record.valid?).to be_falsey
    end
  end
end
