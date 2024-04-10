# frozen_string_literal: true

require 'spec_helper'

describe ActiveModel::Validations::InclusionValidator do
  context 'validates all values are part of a defined list' do
    class TestJsonInclusion < SupplejackCommon::Json::Base
      attribute :dc_type, path: 'dc_type'
      validates :dc_type, inclusion: { in: %w[Images Videos] }
    end

    it 'is valid when all values are part of the list' do
      record = TestJsonInclusion.new('dc_type' => %w[Videos Images])
      record.set_attribute_values
      expect(record).to be_valid
    end

    it 'is not valid when at least one value is not part of the list' do
      record = TestJsonInclusion.new('dc_type' => %w[Videos Photos])
      record.set_attribute_values
      expect(record).not_to be_valid
    end
  end
end
