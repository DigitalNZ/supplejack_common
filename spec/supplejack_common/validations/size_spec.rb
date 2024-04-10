# frozen_string_literal: true

require 'spec_helper'

describe ActiveModel::Validations::SizeValidator do
  context 'validates that the attribute has a maximum number of values' do
    class TestJsonSize < SupplejackCommon::Json::Base
      attribute :landing_url, path: 'landing_url'
      validates :landing_url, size: { maximum: 2 }
    end

    it 'is valid when it has one value' do
      record = TestJsonSize.new('landing_url' => ['http://google.com/1'])
      record.set_attribute_values
      expect(record).to be_valid
    end

    it 'is not valid when it has more than the maximum' do
      record = TestJsonSize.new('landing_url' => ['http://google.com/1', 'http://google.com/2', 'http://google.com/3'])
      record.set_attribute_values
      expect(record).not_to be_valid
    end
  end

  context 'validates that the attribute has the exact number of values' do
    class TestJsonSize < SupplejackCommon::Json::Base
      attribute :landing_url, path: 'landing_url'
      validates :landing_url, size: { is: 1 }
    end

    it 'is valid when it has one value' do
      record = TestJsonSize.new('landing_url' => ['http://google.com/1'])
      record.set_attribute_values
      expect(record).to be_valid
    end

    it 'is not valid when it has 0 values' do
      record = TestJsonSize.new('landing_url' => [])
      record.set_attribute_values
      expect(record).not_to be_valid
    end

    it 'is not valid when it has 2 values' do
      record = TestJsonSize.new('landing_url' => ['http://google.com/1', 'http://google.com/2'])
      record.set_attribute_values
      expect(record).not_to be_valid
    end
  end
end
