# frozen_string_literal: true

require 'spec_helper'

describe SupplejackCommon::AttributeValue do
  let(:value) { described_class.new('Images') }

  describe '#initialize' do
    it 'assigns the original_value and turns it into an array' do
      value = described_class.new('Images')
      value.original_value.should eq ['Images']
    end

    it 'removes empty strings' do
      value = described_class.new('')
      value.original_value.should eq []
    end

    it 'removes nils' do
      value = described_class.new([nil, 'ahoy'])
      value.original_value.should eq ['ahoy']
    end

    it 'should deep clone th original_value' do
      described_class.should_receive(:deep_clone).with(['books'])
      value = described_class.new('books')
    end

    it 'should act as a set' do
      value = described_class.new(%w[1 1])
      value.original_value.should eq ['1']
    end

    it 'should work with the boolean value false' do
      value = described_class.new(false)
      value.original_value.should eq [false]
    end

    it 'should work with the boolean value true' do
      value = described_class.new(true)
      value.original_value.should eq [true]
    end
  end

  describe 'present?' do
    it 'returns true when it has any value' do
      value.stub(:original_value) { ['Images'] }
      value.present?.should be_true
    end

    it "returns false when it doesn't have any value" do
      value.stub(:original_value) { [] }
      value.present?.should be_false
    end
  end

  describe '#downcase' do
    it 'should downcase every value' do
      value = described_class.new(%w[Images Videos])
      value.downcase.original_value.should eq %w[images videos]
    end
  end

  describe '#+' do
    it 'adds the values of two AttributeValue objects' do
      value1 = described_class.new('Images')
      value2 = described_class.new(%w[Videos News])
      value3 = value1 + value2
      value3.original_value.should eq %w[Images Videos News]
    end

    it 'adds the values of a array to a attribute value' do
      value1 = described_class.new('Images')
      value2 = value1 + ['Videos']
      value2.original_value.should eq %w[Images Videos]
    end

    it 'adds a string to a attribute value' do
      value1 = described_class.new('Images')
      value2 = value1 + 'Videos'
      value2.original_value.should eq %w[Images Videos]
    end
  end

  describe '#includes?' do
    context 'string matching' do
      let(:value) { described_class.new('Images') }

      it 'returns true' do
        value.includes?('Images').should be_true
        value.include?('Images').should be_true
      end

      it 'returns false' do
        value.includes?('Videos').should be_false
      end
    end

    context 'regexp matching' do
      let(:value) { described_class.new('Foxes and cats') }

      it 'returns true' do
        value.includes?(/Fox/).should be_true
      end

      it 'returns false' do
        value.includes?(/Tiger/).should be_false
      end
    end
  end

  describe '.deep_clone' do
    it 'deep clones the array of objects' do
      obj1 = 'ben'
      obj2 = 'bill'
      original_array = [obj1, obj2]
      cloned_array = described_class.deep_clone(original_array)
      cloned_array[0].object_id.should_not eq original_array[0].object_id
      cloned_array[1].object_id.should_not eq original_array[1].object_id
    end

    it 'handles fixnums' do
      expect { described_class.deep_clone([1, 2]) }.to_not raise_error(TypeError)
    end
  end
end
