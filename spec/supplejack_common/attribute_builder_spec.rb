# frozen_string_literal: true

require 'spec_helper'

describe SupplejackCommon::AttributeBuilder do
  let(:record) { mock(:record).as_null_object }

  describe '#attribute_value' do
    let(:option_object) { mock(:option, value: 'Google') }

    it 'returns the default value' do
      builder = described_class.new(record, :category, default: 'Google')
      builder.attribute_value.should eq 'Google'
    end

    it 'gets the value from another location' do
      builder = described_class.new(record, :category, xpath: '//category')
      record.should_receive(:strategy_value).with(xpath: '//category') { 'Google' }
      builder.attribute_value.should eq 'Google'
    end
  end

  describe '#evaluate_attribute_block' do
    let(:attr_builder) { described_class.new(record, :authorities, {}) }

    context 'result has redundant white space' do
      it 'strips the white space from the result' do
        attr_builder.evaluate_attribute_block do
          '   1   '
        end.should eq ['1']
      end
    end

    context 'result is just white space' do
      it 'strips the white space from the result' do
        attr_builder.evaluate_attribute_block do
          ['      ', '   ']
        end.should eq []
      end
    end

    context 'result has redundant white space' do
      it 'strips the white space from the result' do
        attr_builder.evaluate_attribute_block do
          '   <b>1</b>   '
        end.should eq ['1']
      end
    end

    context 'block does not return an attribute value object' do
      it 'should create an attribute value object from the block result' do
        SupplejackCommon::AttributeValue.should_receive(:new).with(%w[1 2 3 1])
        attr_builder.evaluate_attribute_block do
          %w[1 2 3 1]
        end
      end

      it 'should return the attribute valueified array' do
        attr_builder.evaluate_attribute_block do
          %w[1 2 3 1]
        end.should eq %w[1 2 3]
      end
    end

    context 'block returns an attribute value object' do
      it 'should return the array from the attribute value object' do
        value = SupplejackCommon::AttributeValue.new(%w[1 2 3 2])
        attr_builder.evaluate_attribute_block do
          value
        end.should eq value.to_a
      end
    end

    context 'block returns nil' do
      it 'should transform the value' do
        attr_builder.stub(:attribute_value) { 'Hi' }
        attr_builder.evaluate_attribute_block do
          nil
        end.should eq attr_builder.transform
      end
    end
  end

  describe '#transform' do
    let(:builder) { described_class.new(record, :category, {}) }

    it 'splits the value' do
      builder = described_class.new(record, :category, separator: ', ')
      builder.stub(:attribute_value) { 'Value1, Value2' }
      builder.transform.should eq %w[Value1 Value2]
    end

    it 'joins the values' do
      builder = described_class.new(record, :category, join: ', ')
      builder.stub(:attribute_value) { %w[Value1 Value2] }
      builder.transform.should eq ['Value1, Value2']
    end

    it 'removes any trailing and leading characters' do
      builder.stub(:attribute_value) { ' Hi ' }
      builder.transform.should eq ['Hi']
    end

    it 'removes any html' do
      builder.stub(:attribute_value) { "<div id='top'>Stripped</div>" }
      builder.transform.should eq ['Stripped']
    end

    it 'truncates the value to 10 charachters' do
      builder = described_class.new(record, :category, truncate: 10)
      builder.stub(:attribute_value) { 'Some random text longer that 10 charachters' }
      builder.transform.should eq ['Some ra...']
    end

    it 'parses a date' do
      builder = described_class.new(record, :category, date: true)
      builder.stub(:attribute_value) { 'circa 1994' }
      builder.transform.should eq [Time.utc(1994, 1, 1, 12)]
    end

    it 'maps the value to another value' do
      builder = described_class.new(record, :category, mappings: { /lucky/ => 'unlucky' })
      builder.stub(:attribute_value) { 'Some lucky squirrel' }
      builder.transform.should eq ['Some unlucky squirrel']
    end

    it 'removes any duplicates' do
      builder.stub(:attribute_value) { %w[Images Images Videos] }
      builder.transform.should eq %w[Images Videos]
    end

    it 'compacts whitespace' do
      builder = described_class.new(record, :category, compact_whitespace: true)
      builder.stub(:attribute_value) { 'Whats   going on   with this     whitespace' }
      builder.transform.should eq ['Whats going on with this whitespace']
    end
  end

  describe '#value' do
    it 'returns the value for the attribute' do
      builder = described_class.new(record, :category, default: 'Video')
      builder.value.should eq ['Video']
    end

    it 'rescues from errors in a block' do
      builder = described_class.new(record, :category, block: proc { raise StandardError, 'Error!' })
      builder.value.should be_nil
      builder.errors.should eq ['Error in the block: Error!']
    end
  end
end
