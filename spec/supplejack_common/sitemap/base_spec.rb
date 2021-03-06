# frozen_string_literal: true

require 'spec_helper'

describe SupplejackCommon::Sitemap::Base do
  let(:klass) { SupplejackCommon::Sitemap::Base }

  describe '.fetch_entries' do
    it 'initializes a set of sitemap records' do
      klass.should_receive(:xml_records).with(nil) { [mock(:sitemap, entry_url: 'Some text')] }
      klass.fetch_entries.should eq ['Some text']
    end
  end

  describe '.sitemap_record_selector' do
    it 'stores the xpath to retrieve every record url' do
      klass.sitemap_entry_selector 'loc'
      klass._record_selector.should eq 'loc'
    end
  end

  describe '.clear_definitions' do
    it 'clears the sitemap format' do
      klass._record_selector = '//loc'
      klass.clear_definitions
      klass._record_selector.should be_nil
    end
  end
end
