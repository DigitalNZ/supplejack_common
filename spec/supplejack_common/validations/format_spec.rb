# frozen_string_literal: true

require 'spec_helper'

describe ActiveModel::Validations::FormatValidator do
  context 'validates all values have the correct format' do
    class TestJsonWith < SupplejackCommon::Json::Base
      attribute :dc_type, path: 'dc_type'
      validates :dc_type, format: { with: /Images|Videos/ }
    end

    it 'is valid' do
      record = TestJsonWith.new('dc_type' => %w[Videos Images])
      record.set_attribute_values
      expect(record).to be_valid
    end

    it "is not valid when at least one value doesn't match" do
      record = TestJsonWith.new('dc_type' => %w[Videos Photos])
      record.set_attribute_values
      expect(record).not_to be_valid
    end
  end

  context "validates all values don't match the regexp" do
    class TestJsonWithout < SupplejackCommon::Json::Base
      attribute :dc_type, path: 'dc_type'
      validates :dc_type, format: { without: /Images|Videos/ }
    end

    it 'is valid' do
      record = TestJsonWithout.new('dc_type' => %w[Photos Manuscripts])
      record.set_attribute_values
      expect(record).to be_valid
    end

    it 'is not valid when at least one value matches the without regexp' do
      record = TestJsonWithout.new('dc_type' => %w[Videos Photos])
      record.set_attribute_values
      expect(record).not_to be_valid
    end
  end
end
