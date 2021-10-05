# frozen_string_literal: true

require 'spec_helper'

describe SupplejackCommon::Sitemap::Base do
  describe '.fetch_entries' do
    it 'initializes a set of sitemap records' do
      described_class.should_receive(:xml_records).with(nil) { [mock(:sitemap, entry_url: 'Some text')] }
      described_class.fetch_entries.should eq ['Some text']
    end
  end

  describe '.sitemap_record_selector' do
    it 'stores the xpath to retrieve every record url' do
      described_class.sitemap_entry_selector 'loc'
      described_class._record_selector.should eq 'loc'
    end
  end

  describe '.clear_definitions' do
    it 'clears the sitemap format' do
      described_class._record_selector = '//loc'
      described_class.clear_definitions
      described_class._record_selector.should be_nil
    end
  end
end
