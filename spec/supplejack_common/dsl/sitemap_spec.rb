# frozen_string_literal: true

require 'spec_helper'

class TestXmlParser < SupplejackCommon::Xml::Base; end

describe SupplejackCommon::Dsl::Sitemap do
  let(:klass) { TestXmlParser }

  describe '.sitemap_entry_selector' do
    it 'should set the sitemap entry selector' do
      klass.sitemap_entry_selector('//loc')
      expect(klass._sitemap_entry_selector).to eq '//loc'
    end
  end
end
