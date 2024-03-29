# frozen_string_literal: true

require 'spec_helper'

describe SupplejackCommon::PaginatedCollection do
  let(:klass) { SupplejackCommon::PaginatedCollection }
  let(:collection) { klass.new(SupplejackCommon::Base, { page_parameter: 'page', type: 'item', per_page_parameter: 'per_page', per_page: 5, page: 1, counter: 1 }, limit: 1) }

  describe '#initialize' do
    it 'assigns the klass' do
      collection.klass.should eq SupplejackCommon::Base
    end

    it 'initializes pagination options' do
      collection.page_parameter.should eq 'page'
      collection.per_page_parameter.should eq 'per_page'
      collection.per_page.should eq 5
      collection.page.should eq 1
    end

    it 'initializes a counter and extra options' do
      collection.counter.should eq 1
      collection.options.should eq(limit: 1)
    end
  end

  describe '#each' do
    before do
      collection.klass.stub(:base_urls) { ['http://go.gle/', 'http://dnz.harvest/1'] }
      collection.stub(:yield_from_records) { true }
      collection.stub(:paginated?) { false }
    end

    it 'should process all base_urls' do
      SupplejackCommon::Base.should_receive(:fetch_records).with('http://go.gle/')
      SupplejackCommon::Base.should_receive(:fetch_records).with('http://dnz.harvest/1')
      collection.each { ; }
    end

    context 'paginated' do
      before do
        collection.stub(:paginated?) { true }
        collection.stub(:url_options) { { page: 1, per_page: 10 } }
        collection.klass.stub(:base_urls) { ['http://go.gle/', 'http://dnz.harvest/1'] }
        SupplejackCommon::Base.stub(:total_results) { 1 }
      end

      it 'should call fetch records with a paginated url' do
        SupplejackCommon::Base.should_receive(:fetch_records).with('http://go.gle/?page=1&per_page=10')
        SupplejackCommon::Base.should_receive(:fetch_records).with('http://dnz.harvest/1?page=1&per_page=10')
        collection.each { ; }
      end
    end
  end

  describe '#paginated?' do
    it 'returns true when page and per_page are set' do
      collection.send(:paginated?).should be_true
    end

    it 'returns false when no pagination options are set' do
      collection = klass.new(SupplejackCommon::Base, nil, {})
      collection.send(:paginated?).should be_false
    end
  end

  describe '#next_url' do
    context 'paginated' do
      before do
        collection.stub(:paginated?) { true }
        collection.stub(:url_options) { { page: 1, per_page: 10 } }
      end

      it 'returns the url with paginated options' do
        collection.send(:next_url, 'http://go.gle/').should eq 'http://go.gle/?page=1&per_page=10'
      end

      it 'appends to existing url parameters' do
        collection.send(:next_url, 'http://go.gle/?sort=asc').should eq 'http://go.gle/?sort=asc&page=1&per_page=10'
      end

      it 'should call a block if given' do
        collec = klass.new(SupplejackCommon::Base, { page_parameter: 'page', type: 'item', block:
          proc { 'http://google.com' } })
        collec.send(:next_url, 'http://go.gle/?sort=asc').should eq 'http://google.com'
      end
    end

    context 'not paginated' do
      before { collection.stub(:paginated?) }

      it 'returns the url passed' do
        collection.send(:next_url, 'http://goog.gle').should eq 'http://goog.gle'
      end
    end

    context 'tokenised pagination' do
      let(:params) do
        { page_parameter: 'page-parameter',
          type: 'token',
          per_page_parameter: 'per_page',
          per_page: 5,
          next_page_token_location: 'next_page_token',
          page: 1 }
      end
      let(:collection) { klass.new(SupplejackCommon::Base, params, limit: 1) }

      before do
        SupplejackCommon::Base.stub(:next_page_token) { 'abc_1234' }
        SupplejackCommon::Base.stub(:_document) { true }
      end

      it 'generates the next url' do
        expect(collection.send(:next_url, 'http://go.gle/?sort=asc')).to eq 'http://go.gle/?sort=asc&page-parameter=abc_1234&per_page=5'
      end
    end

    context 'scroll API' do
      context 'when the content partner has a standard ElasticSearch set up' do
        let(:params) { { type: 'scroll', duration_parameter: 'scroll', duration_value: '1m' } }
        let(:collection) { klass.new(SupplejackCommon::Base, params) }

        context 'when the _document is present' do
          before do
            SupplejackCommon::Base.stub(:_document) { OpenStruct.new(body: '{ "_scroll_id": "scroll_id" }') }
          end

          it 'generates the next url based on the response payload' do
            expect(collection.send(:next_url, 'http://google/search/collectionsonline/_search?scroll=10m&q=334')).to eq 'http://google/search/_search/scroll/scroll_id?scroll=1m'
          end
        end

        context 'when the _document is not present' do
          before do
            SupplejackCommon::Base.stub(:_document) { nil }
          end

          it 'uses the URL it was instantiated with' do
            expect(collection.send(:next_url, 'http://google/collection/_scroll')).to eq 'http://google/collection/_scroll?scroll=1m'
          end
        end
      end

      context 'when the next_scroll_url_block is provided' do
        let(:params) do
          { type: 'scroll', duration_parameter: 'scrolling_duration', duration_value: '10m', next_scroll_url_block: proc do |url, klass|
                                                                                                                      url.match('(?<base_url>.+\/collection)')[:base_url] + klass._document.headers[:location]
                                                                                                                    end }
        end
        let(:collection) { klass.new(SupplejackCommon::Base, params) }

        context 'when the _document is present' do
          before do
            SupplejackCommon::Base.stub(:_document) { OpenStruct.new(headers: OpenStruct.new(location: '/scroll/scroll_token/pages')) }
          end

          it 'generates the next url based on the header :location in the response' do
            expect(collection.send(:next_url, 'http://google/collection/_scroll')).to eq 'http://google/collection/scroll/scroll_token/pages?scrolling_duration=10m'
          end
        end

        context 'when the _document is not present' do
          before do
            SupplejackCommon::Base.stub(:_document) { nil }
          end

          it 'uses the url that it was instantiated with' do
            expect(collection.send(:next_url, 'http://google/collection/_scroll')).to eq 'http://google/collection/_scroll?scrolling_duration=10m'
          end

          context 'when duration_value is not present' do
            let(:params) { { type: 'scroll', duration_parameter: 'scrolling_duration' } }

            it 'does not add any query params' do
              expect(collection.send(:next_url, 'http://google/collection/_scroll')).to eq 'http://google/collection/_scroll?'
            end
          end

          context 'when duration_parameter is not present' do
            let(:params) { { type: 'scroll', duration_value: '1m' } }

            it 'does not add any query params' do
              expect(collection.send(:next_url, 'http://google/collection/_scroll')).to eq 'http://google/collection/_scroll?'
            end
          end

          context 'when duration_parameter and duration_value are not present' do
            let(:params) { { type: 'scroll' } }

            it 'does not add any query params' do
              expect(collection.send(:next_url, 'http://google/collection/_scroll')).to eq 'http://google/collection/_scroll?'
            end
          end
        end
      end
    end

    context 'with initial parameter' do
      let(:params) do
        { page_parameter: 'page-parameter',
          type: 'token',
          initial_param: 'initial-paramater=true' }
      end
      let(:collection) { klass.new(SupplejackCommon::Base, params, limit: 1) }

      before do
        SupplejackCommon::Base.stub(:next_page_token) { 'abc_1234' }
        SupplejackCommon::Base.stub(:_document) { true }
      end

      it 'generates a url with an initial parameter' do
        expect(collection.send(:next_url, 'http://go.gle/?sort=asc')).to eq 'http://go.gle/?sort=asc&initial-paramater=true'
      end

      it 'generates next url without initial parameter after the first call' do
        expect(collection.send(:next_url, 'http://go.gle/?sort=asc')).to eq 'http://go.gle/?sort=asc&initial-paramater=true'
        expect(collection.send(:next_url, 'http://go.gle/?sort=asc')).to eq 'http://go.gle/?sort=asc&page-parameter=abc_1234'
      end
    end
  end

  describe '#url_options' do
    it 'returns a hash with the url options' do
      collection.send(:url_options).should eq('page' => 1, 'per_page' => 5)
    end

    it 'removes nil keys from the hash of url options' do
      collection = klass.new(SupplejackCommon::Base, page_parameter: 'page', page: 1, type: 'item', per_page_parameter: nil)
      collection.send(:url_options).should eq('page' => 1)
    end
  end

  describe '#current_page' do
    context 'page type pagination' do
      let(:collection) { klass.new(SupplejackCommon::Base, page_parameter: 'page', type: 'page', per_page_parameter: 'per_page', per_page: 5, page: 1) }

      it 'returns the current_page' do
        collection.send(:current_page).should eq 1
      end
    end

    context 'item type pagination' do
      let(:collection) { klass.new(SupplejackCommon::Base, page_parameter: 'page', type: 'item', per_page_parameter: 'per_page', per_page: 5, page: 1) }

      it 'returns the first page' do
        collection.send(:current_page).should eq 1
      end

      it 'returns the second page' do
        collection.stub(:page) { 6 }
        collection.send(:current_page).should eq 2
      end

      it 'returns the third page' do
        collection.stub(:page) { 11 }
        collection.send(:current_page).should eq 3
      end
    end
  end

  describe '#total_pages' do
    it 'returns the total number of pages' do
      SupplejackCommon::Base.stub(:total_results) { 40 }
      collection.stub(:per_page) { 10 }
      collection.send(:total_pages).should eq 4
    end

    it 'returns the total number of pages even when the last page is not full of records' do
      SupplejackCommon::Base.stub(:total_results) { 41 }
      collection.stub(:per_page) { 10 }
      collection.send(:total_pages).should eq 5
    end
  end

  describe 'increment_page_counter!' do
    context 'page type pagination' do
      let(:collection) { klass.new(SupplejackCommon::Base, page_parameter: 'page', type: 'page', per_page_parameter: 'per_page', per_page: 5, page: 1) }

      it 'increments the page by one' do
        collection.send(:increment_page_counter!)
        collection.page.should eq 2
      end
    end

    context 'item type pagination' do
      let(:collection) { klass.new(SupplejackCommon::Base, page_parameter: 'page', type: 'item', per_page_parameter: 'per_page', per_page: 5, page: 1) }

      it 'increments the page by the number per_page' do
        collection.send(:increment_page_counter!)
        collection.page.should eq 6
      end
    end
  end

  describe '#more_results?' do
    context 'when the harvest pagination type is scroll' do
      context 'when the scroll more results block is not provided' do
        let(:params) { { type: 'scroll', duration_parameter: 'scroll', duration_value: '1m' } }
        let(:collection) { klass.new(SupplejackCommon::Base, params) }

        it 'returns true when the document returns that there are hits on the current page' do
          SupplejackCommon::Base.stub(:_document) { OpenStruct.new(body: '{"hits":{"total":{"value":34,"relation":"eq"},"max_score":15.885282,"hits":["a"]}}') }

          expect(collection.send(:more_results?)).to eq true
        end

        it 'returns false when the document returns that there are no hits on the current page' do
          SupplejackCommon::Base.stub(:_document) { OpenStruct.new(body: '{"hits":{"total":{"value":34,"relation":"eq"},"max_score":15.885282,"hits":[]}}') }

          expect(collection.send(:more_results?)).to eq false
        end
      end

      context 'when the harvests scroll_more_results_block is provided' do
        let(:params) { { type: 'scroll', duration_parameter: 'scroll', duration_value: '1m', scroll_more_results_block: proc { |klass| klass._document.code == 303 } } }
        let(:collection) { klass.new(SupplejackCommon::Base, params) }

        it 'returns true when the response code is 303' do
          SupplejackCommon::Base.stub(:_document) { OpenStruct.new(code: 303) }

          expect(collection.send(:more_results?)).to eq true
        end

        it 'returns false when the response code is not 303' do
          SupplejackCommon::Base.stub(:_document) { OpenStruct.new(code: 200) }

          expect(collection.send(:more_results?)).to eq false
        end
      end
    end
  end
end
