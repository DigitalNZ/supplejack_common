# frozen_string_literal: true

require 'spec_helper'

describe SupplejackCommon::DSL do
  subject { SupplejackCommon::Base }

  before(:each) do
    subject.clear_definitions
  end

  describe '.base_url' do
    it 'adds the base_url' do
      subject.base_url 'http://google.com'
      expect(subject.base_urls).to include 'http://google.com'
    end

    it 'appends to a existing array of urls' do
      subject.base_url 'http://google.com'
      subject.base_url 'http://apple.com'
      expect(subject.base_urls).to include 'http://apple.com'
      expect(subject.base_urls.size).to eq 2
    end
  end

  describe '.http_headers' do
    it 'stores the header name and value' do
      subject.http_headers('Authorization': 'Token token="token"', 'x-api-key': 'gus')

      expect(subject._http_headers).to eq('Authorization': 'Token token="token"', 'x-api-key': 'gus')
    end
  end

  describe '.basic_auth' do
    it 'should set the basic auth username and password' do
      subject.basic_auth 'username', 'password'
      expect(subject._basic_auth[subject.identifier]).to eq(username: 'username', password: 'password')
    end
  end

  describe '.paginate' do
    let(:pagination) { double(:pagination) }
    let(:options) { { page_parameter: 'start-index', type: 'item', per_page_parameter: 'max-results', per_page: 50, page: 1 } }

    it 'initializes a pagination object' do
      subject.paginate options
      expect(subject._pagination_options[subject.identifier]).to eq options
    end

    it 'stores the block' do
      subject.paginate options do
        'http://google.com'
      end

      expect(subject._pagination_options[subject.identifier][:block]).to be_a Proc
    end
  end

  describe '.attribute' do
    it 'adds a new attribute definition' do
      subject.attribute :category, option: true
      expect(subject.attribute_definitions).to include(category: { option: true })
    end

    it 'defaults to a empty set of options' do
      subject.attribute :category
      expect(subject.attribute_definitions).to include(category: {})
    end

    it 'stores the block' do
      subject.attribute :category do
        last(:description)
      end

      expect(subject.attribute_definitions[:category][:block]).to be_a Proc
    end
  end

  describe '.attributes' do
    it 'adds multiple attribute definitions' do
      subject.attributes :category, :creator, option: true
      expect(subject.attribute_definitions).to include(category: { option: true })
      expect(subject.attribute_definitions).to include(creator: { option: true })
    end

    it 'adds multiple attributes with a block' do
      subject.attributes :category, :creator do
        'Hi'
      end

      expect(subject.attribute_definitions[:category][:block]).to be_a(Proc)
      expect(subject.attribute_definitions[:category][:block]).to be_a(Proc)
    end
  end

  describe '.enrichment' do
    context 'with block' do
      let!(:block) { proc { 'Hi' } }

      it 'adds a enrichment definition' do
        subject.enrichment :ndha_rights, &block
        expect(subject.enrichment_definitions[:ndha_rights]).to eq(block: block)
      end
    end
  end

  describe '.with_options' do
    it 'adds a attribute definition with the options' do
      class WithOptionsTest < SupplejackCommon::Base
        with_options xpath: 'name', if: { 'span' => :label }, value: 'div' do |w|
          w.attribute :title, label: 'Name'
        end
      end

      expect(WithOptionsTest.attribute_definitions).to include(title: { xpath: 'name', if: { 'span' => 'Name' }, value: 'div' })
    end
  end

  describe '.reject_if' do
    it 'adds a new rejection rule' do
      subject.reject_if { 'value' }
      expect(subject._rejection_rules[subject.identifier].first).to be_a Proc
    end
  end

  describe '.delete_if' do
    it 'adds the new delete rule' do
      subject.delete_if { 'value' }
      expect(subject._deletion_rules[subject.identifier]).to be_a Proc
    end
  end

  describe '.throttle' do
    before do
      subject._throttle = nil
    end

    it 'should store the throttling information' do
      subject.throttle host: 'gdata.youtube.com', max_per_minute: 100
      expect(subject._throttle).to eq [{ host: 'gdata.youtube.com', max_per_minute: 100 }]
    end

    it 'should store multiple throttle options' do
      subject.throttle host: 'www.google.com', max_per_minute: 100
      subject.throttle host: 'www.yahoo.com', max_per_minute: 100
      expect(subject._throttle).to eq [{ host: 'www.google.com', max_per_minute: 100 }, { host: 'www.yahoo.com', max_per_minute: 100 }]
    end
  end

  describe '.request_timeout' do
    before do
      subject._request_timeout = nil
    end

    it 'should store the timeout information' do
      subject.request_timeout(10_000)
      expect(subject._request_timeout).to eq 10_000
    end
  end

  describe '.priority' do
    it 'stores the prioriy' do
      subject.priority 2
      expect(subject._priority[subject.identifier]).to eq 2
    end
  end

  describe '.match_concepts' do
    it 'stores the match concept rule' do
      subject.match_concepts :create_or_match
      expect(subject._match_concepts[subject.identifier]).to eq :create_or_match
    end
  end

  describe '.pre_process_block' do
    it 'store given block to _pre_process_block class variable so it can be used to process raw data from source' do
      subject.pre_process_block do |data|
        data
      end

      expect(subject._pre_process_block.call(123)).to eq 123
    end
  end
end
