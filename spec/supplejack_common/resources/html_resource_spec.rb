# frozen_string_literal: true

require 'spec_helper'

describe SupplejackCommon::HtmlResource do
  subject { described_class.new('http://google.com/1', {}) }

  describe '#document' do
    it 'should parse the resource as HTML' do
      allow(subject).to receive(:fetch_document) { '</html>' }
      expect(subject.document).to be_a Nokogiri::HTML::Document
    end
  end
end
