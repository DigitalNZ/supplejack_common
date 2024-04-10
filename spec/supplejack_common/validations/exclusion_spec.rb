# frozen_string_literal: true

require 'spec_helper'

describe ActiveModel::Validations::ExclusionValidator do
  context 'validates none of the values are part of a defined list' do
    class TestJsonExclusion < SupplejackCommon::Json::Base
      attribute :dc_type, path: 'dc_type'
      validates :dc_type, exclusion: { in: %w[Images Videos] }
    end

    it 'is valid when none of the values are part of the list' do
      record = TestJsonExclusion.new('dc_type' => %w[Photos Manuscripts])
      record.set_attribute_values
      expect(record).to be_valid
    end

    it 'is not valid when at least one value is part of the list' do
      record = TestJsonExclusion.new('dc_type' => %w[Videos Photos])
      record.set_attribute_values
      expect(record).not_to be_valid
    end
  end
end
