# frozen_string_literal: true

require 'spec_helper'

describe SupplejackCommon::Sitemap::Base do
  describe '.fetch_entries' do
    it 'initializes a set of sitemap records' do
      expect(described_class).to receive(:xml_records).with(nil) { [double(:sitemap, entry_url: 'Some text')] }
      expect(described_class.fetch_entries).to eq ['Some text']
    end
  end

  describe '.sitemap_record_selector' do
    it 'stores the xpath to retrieve every record url' do
      described_class.sitemap_entry_selector 'loc'
      expect(described_class._record_selector).to eq 'loc'
    end
  end

  describe '.clear_definitions' do
    it 'clears the sitemap format' do
      described_class._record_selector = '//loc'
      described_class.clear_definitions
      expect(described_class._record_selector).to be_nil
    end
  end
end
