# frozen_string_literal: true

require 'spec_helper'

describe SupplejackCommon::AttributeValue do
  let(:value) { described_class.new('Images') }

  describe '#initialize' do
    it 'assigns the original_value and turns it into an array' do
      value = described_class.new('Images')
      expect(value.original_value).to eq ['Images']
    end

    it 'removes empty strings' do
      value = described_class.new('')
      expect(value.original_value).to eq []
    end

    it 'removes nils' do
      value = described_class.new([nil, 'ahoy'])
      expect(value.original_value).to eq ['ahoy']
    end

    it 'should deep clone th original_value' do
      expect(described_class).to receive(:deep_clone).with(['books'])
      value = described_class.new('books')
    end

    it 'should act as a set' do
      value = described_class.new(%w[1 1])
      expect(value.original_value).to eq ['1']
    end

    it 'should work with the boolean value false' do
      value = described_class.new(false)
      expect(value.original_value).to eq [false]
    end

    it 'should work with the boolean value true' do
      value = described_class.new(true)
      expect(value.original_value).to eq [true]
    end
  end

  describe 'present?' do
    it 'returns true when it has any value' do
      allow(value).to receive(:original_value) { ['Images'] }
      expect(value.present?).to be_truthy
    end

    it "returns false when it doesn't have any value" do
      allow(value).to receive(:original_value) { [] }
      expect(value.present?).to be_falsey
    end
  end

  describe '#downcase' do
    it 'should downcase every value' do
      value = described_class.new(%w[Images Videos])
      expect(value.downcase.original_value).to eq %w[images videos]
    end
  end

  describe '#+' do
    it 'adds the values of two AttributeValue objects' do
      value1 = described_class.new('Images')
      value2 = described_class.new(%w[Videos News])
      value3 = value1 + value2
      expect(value3.original_value).to eq %w[Images Videos News]
    end

    it 'adds the values of a array to a attribute value' do
      value1 = described_class.new('Images')
      value2 = value1 + ['Videos']
      expect(value2.original_value).to eq %w[Images Videos]
    end

    it 'adds a string to a attribute value' do
      value1 = described_class.new('Images')
      value2 = value1 + 'Videos'
      expect(value2.original_value).to eq %w[Images Videos]
    end
  end

  describe '#includes?' do
    context 'string matching' do
      let(:value) { described_class.new('Images') }

      it 'returns true' do
        expect(value.includes?('Images')).to be_truthy
        expect(value.include?('Images')).to be_truthy
      end

      it 'returns false' do
        expect(value.includes?('Videos')).to be_falsey
      end
    end

    context 'regexp matching' do
      let(:value) { described_class.new('Foxes and cats') }

      it 'returns true' do
        expect(value.includes?(/Fox/)).to be_truthy
      end

      it 'returns false' do
        expect(value.includes?(/Tiger/)).to be_falsey
      end
    end
  end

  describe '.deep_clone' do
    it 'deep clones the array of objects' do
      obj1 = 'ben'
      obj2 = 'bill'
      original_array = [obj1, obj2]
      cloned_array = described_class.deep_clone(original_array)
      expect(cloned_array[0].object_id).not_to eq original_array[0].object_id
      expect(cloned_array[1].object_id).not_to eq original_array[1].object_id
    end

    it 'handles fixnums' do
      expect { described_class.deep_clone([1, 2]) }.to_not raise_error
    end
  end
end
