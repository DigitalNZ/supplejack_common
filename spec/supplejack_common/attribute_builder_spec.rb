# frozen_string_literal: true

require 'spec_helper'

describe SupplejackCommon::AttributeBuilder do
  let(:record) { double(:record).as_null_object }

  describe '#attribute_value' do
    let(:option_object) { double(:option, value: 'Google') }

    it 'returns the default value' do
      builder = described_class.new(record, :category, default: 'Google')
      expect(builder.attribute_value).to eq 'Google'
    end

    it 'gets the value from another location' do
      builder = described_class.new(record, :category, xpath: '//category')
      expect(record).to receive(:strategy_value).with({ xpath: '//category' }) { 'Google' }
      expect(builder.attribute_value).to eq 'Google'
    end
  end

  describe '#evaluate_attribute_block' do
    let(:attr_builder) { described_class.new(record, :authorities, {}) }

    context 'result has redundant white space' do
      it 'strips the white space from the result' do
        expect(attr_builder.evaluate_attribute_block do
          '   1   '
        end).to eq ['1']
      end
    end

    context 'result is just white space' do
      it 'strips the white space from the result' do
        expect(attr_builder.evaluate_attribute_block do
          ['      ', '   ']
        end).to eq []
      end
    end

    context 'result has redundant white space' do
      it 'strips the white space from the result' do
        expect(attr_builder.evaluate_attribute_block do
          '   <b>1</b>   '
        end).to eq ['1']
      end
    end

    context 'block does not return an attribute value object' do
      it 'should create an attribute value object from the block result' do
        expect(SupplejackCommon::AttributeValue).to receive(:new).with(%w[1 2 3 1])
        attr_builder.evaluate_attribute_block do
          %w[1 2 3 1]
        end
      end

      it 'should return the attribute valueified array' do
        expect(attr_builder.evaluate_attribute_block do
          %w[1 2 3 1]
        end).to eq %w[1 2 3]
      end
    end

    context 'block returns an attribute value object' do
      it 'should return the array from the attribute value object' do
        value = SupplejackCommon::AttributeValue.new(%w[1 2 3 2])
        expect(attr_builder.evaluate_attribute_block do
          value
        end).to eq value.to_a
      end
    end

    context 'block returns nil' do
      it 'should transform the value' do
        allow(attr_builder).to receive(:attribute_value) { 'Hi' }
        expect(attr_builder.evaluate_attribute_block do
          nil
        end).to eq attr_builder.transform
      end
    end
  end

  describe '#transform' do
    let(:builder) { described_class.new(record, :category, {}) }

    it 'splits the value' do
      builder = described_class.new(record, :category, separator: ', ')
      allow(builder).to receive(:attribute_value) { 'Value1, Value2' }
      expect(builder.transform).to eq %w[Value1 Value2]
    end

    it 'joins the values' do
      builder = described_class.new(record, :category, join: ', ')
      allow(builder).to receive(:attribute_value) { %w[Value1 Value2] }
      expect(builder.transform).to eq ['Value1, Value2']
    end

    it 'removes any trailing and leading characters' do
      allow(builder).to receive(:attribute_value) { ' Hi ' }
      expect(builder.transform).to eq ['Hi']
    end

    it 'removes any html' do
      allow(builder).to receive(:attribute_value) { "<div id='top'>Stripped</div>" }
      expect(builder.transform).to eq ['Stripped']
    end

    it 'truncates the value to 10 charachters' do
      builder = described_class.new(record, :category, truncate: 10)
      allow(builder).to receive(:attribute_value) { 'Some random text longer that 10 charachters' }
      expect(builder.transform).to eq ['Some ra...']
    end

    it 'parses a date' do
      builder = described_class.new(record, :category, date: true)
      allow(builder).to receive(:attribute_value) { 'circa 1994' }
      expect(builder.transform).to eq [Time.utc(1994, 1, 1, 12)]
    end

    it 'maps the value to another value' do
      builder = described_class.new(record, :category, mappings: { /lucky/ => 'unlucky' })
      allow(builder).to receive(:attribute_value) { 'Some lucky squirrel' }
      expect(builder.transform).to eq ['Some unlucky squirrel']
    end

    it 'removes any duplicates' do
      allow(builder).to receive(:attribute_value) { %w[Images Images Videos] }
      expect(builder.transform).to eq %w[Images Videos]
    end

    it 'compacts whitespace' do
      builder = described_class.new(record, :category, compact_whitespace: true)
      allow(builder).to receive(:attribute_value) { 'Whats   going on   with this     whitespace' }
      expect(builder.transform).to eq ['Whats going on with this whitespace']
    end
  end

  describe '#value' do
    it 'returns the value for the attribute' do
      builder = described_class.new(record, :category, default: 'Video')
      expect(builder.value).to eq ['Video']
    end

    it 'rescues from errors in a block' do
      builder = described_class.new(record, :category, block: proc { raise StandardError, 'Error!' })
      expect(builder.value).to be_nil
      expect(builder.errors).to eq ['Error in the block: Error!']
    end
  end
end
