# frozen_string_literal: true

require 'spec_helper'

describe SupplejackCommon::HtmlResource do
  subject { described_class.new('http://google.com/1', {}) }

  describe '#document' do
    it 'should parse the resource as HTML' do
      subject.stub(:fetch_document) { '</html>' }
      subject.document.should be_a Nokogiri::HTML::Document
    end
  end
end
