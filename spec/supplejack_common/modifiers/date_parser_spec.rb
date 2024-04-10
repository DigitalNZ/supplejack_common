# frozen_string_literal: false

require 'spec_helper'

describe SupplejackCommon::Modifiers::DateParser do
  let(:parse_date) { described_class.new('2012-10-10', true) }

  describe '#initialize' do
    it 'assigns the original value and optional format' do
      expect(parse_date.original_value).to eq ['2012-10-10']
      expect(parse_date.format).to be_nil
    end
  end

  describe '#modify' do
    it 'parses the date with Chronic' do
      allow(parse_date).to receive(:original_value).and_return(['1st of January 1997'])
      expect(parse_date.modify).to eq [Time.utc(1997, 1, 1, 12)]
    end

    it 'parses the date with a specific format' do
      allow(parse_date).to receive_messages(original_value: ['01/12/1997'], format: '%d/%m/%Y')
      expect(parse_date.modify).to eq [Time.utc(1997, 12, 1)]
    end

    it 'parses a circa date' do
      allow(parse_date).to receive(:original_value).and_return(['circa 1994'])
      expect(parse_date.modify).to eq [Time.utc(1994, 1, 1, 12)]
    end

    it 'parses a decade date (1940s)' do
      allow(parse_date).to receive(:original_value).and_return(['1940s'])
      expect(parse_date.modify).to eq [Time.utc(1940, 1, 1, 12)]
    end
  end

  describe '#parse_date' do
    it 'rescues from from a Chronic exception' do
      allow(Chronic).to receive(:parse).and_raise(StandardError.new('ArgumentError - invalid date'))
      parse_date.parse_date('2009/1/1')
      expect(parse_date.errors).to eq ["Cannot parse date: '2009/1/1', ArgumentError - invalid date"]
    end

    it 'rescues from a DateTime exception' do
      allow(parse_date).to receive(:format).and_return('%d %m %Y')
      allow(DateTime).to receive(:strptime).and_raise(StandardError.new('ArgumentError - invalid date'))
      parse_date.parse_date('2009/1/1')
      expect(parse_date.errors).to eq ["Cannot parse date: '2009/1/1', ArgumentError - invalid date"]
    end

    it 'returns the same time object' do
      time = Time.now
      expect(parse_date.parse_date(time)).to eq time
    end

    it 'parsers a standard time with time zone' do
      time = Time.parse('Fri, 21 Dec 2012 12:12:00 +1300')
      expect(parse_date.parse_date('Fri, 21 Dec 2012 12:12:00 +1300')).to eq time
    end
  end

  describe '#normalized' do
    it 'converts a circa year into a date' do
      expect(parse_date.normalized('circa 1994')).to eq '1994/1/1'
    end

    it 'converts a decade date into a date' do
      expect(parse_date.normalized('1994s')).to eq '1994/1/1'
    end

    it 'converts a year into a date' do
      expect(parse_date.normalized('1994')).to eq '1994/1/1'
    end
  end
end
