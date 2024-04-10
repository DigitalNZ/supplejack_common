# frozen_string_literal: true

require 'spec_helper'

describe SupplejackCommon::Request do
  # let!(:described_class) { SupplejackCommon::Request }
  let!(:request) { described_class.new('http://google.com/titles/1', 10_000) }

  before(:each) do
    allow(RestClient::Request).to receive(:execute) { 'body' }
  end

  describe '.get' do
    before(:each) do
      allow(described_class).to receive(:new) { request }
    end

    it 'initializes a request object' do
      expect(described_class).to receive(:new).with('google.com', nil, [{ delay: 1 }], {}, nil) { request }
      described_class.get('google.com', nil, [{ delay: 1 }])
    end

    it 'should fetch the resource and returns it' do
      expect(request).to receive(:get) { 'body' }
      expect(described_class.get('google.com', nil)).to eq 'body'
    end

    it 'should set the request_timeout' do
      expect(request.request_timeout).to eq 10_000
    end
  end

  describe '#initialize' do
    it 'converts the array of throttling options to a hash' do
      request = described_class.new('google.com', 60_000,
                                    [{ host: 'google.com', delay: 5 }, { host: 'yahoo.com', delay: 10 }])
      expect(request.throttling_options).to eq('google.com' => 5, 'yahoo.com' => 10)
    end

    it 'handles nil options' do
      request = described_class.new('google.com', nil)
      expect(request.throttling_options).to eq({})
    end

    it 'can be initialized with headers' do
      headers = { 'x-api-key' => 'API_KEY', 'Authorization' => 'tokentokentoken' }

      request = described_class.new('', '', [], headers)
      expect(request.headers).to eq headers
    end
  end

  describe '#uri' do
    it 'should initialize a URI from the url' do
      expect(request.uri).to eq URI.parse('http://google.com/titles/1')
    end
  end

  describe '#host' do
    it 'returns the request url host' do
      expect(described_class.new('http://gdata.youtube.com/feeds/api/videos?author=archivesnz&orderby=published',
                                 60_000).host).to eq 'gdata.youtube.com'
    end
  end

  describe 'get' do
    let!(:time) { Time.now }

    before(:each) do
      allow(Time).to receive(:now) { time }
    end

    it 'should aquire the lock' do
      expect(request).to receive(:acquire_lock)
      request.get
    end

    it 'should request the resource' do
      expect(request).to receive(:request_resource) { 'body' }
      expect(request.get).to eq 'body'
    end
  end

  describe '#scroll' do
    let(:initial_request)    { described_class.new('http://google.com/collection/_scroll', 10_000, {}, 'x-api-key' => 'key') }
    let(:subsequent_request) { described_class.new('http://google.com/collection/scroll', 10_000, {}, 'x-api-key' => 'key') }

    it 'should aquire the lock' do
      expect(request).to receive(:acquire_lock)
      request.scroll
    end

    it 'should do a POST request initially and NOT follow redirects' do
      expect(RestClient::Request).to receive(:execute).with(method: :post,
                                                            url: 'http://google.com/collection/_scroll',
                                                            timeout: 10_000,
                                                            headers: { 'x-api-key' => 'key' }, max_redirects: 0)
      initial_request.scroll
    end

    it 'should follow up with subsequent GET requests and NOT follow redirects' do
      expect(RestClient::Request).to receive(:execute).with(method: :get,
                                                            url: 'http://google.com/collection/scroll',
                                                            timeout: 10_000,
                                                            headers: { 'x-api-key' => 'key' }, max_redirects: 0)
      subsequent_request.scroll
    end
  end

  describe '#acquire_lock' do
    let(:mock_redis) { double(:redis).as_null_object }

    before do
      allow(request).to receive(:request_resource)
      allow(SupplejackCommon).to receive(:redis) { mock_redis }
      allow(request).to receive(:delay) { 2000 }
    end

    it 'should set a key of host in redis' do
      expect(mock_redis).to receive(:setnx).with('harvester.throttle.google.com', 0)
      request.acquire_lock {}
    end

    it 'should set the expiry of the key' do
      expect(mock_redis).to receive(:pexpire).with('harvester.throttle.google.com', 2000)
      request.acquire_lock {}
    end

    context 'could not acquire lock' do
      before do
        allow(mock_redis).to receive(:setnx).and_return(false, true) # fails the first time, then succeeds
      end

      it 'should sleep for the time left' do
        allow(mock_redis).to receive(:pttl).with('harvester.throttle.google.com') { 1234 }
        expect(request).to receive(:sleep).with(1.244)
        request.acquire_lock {}
      end

      it 'should sleep for the whole delay is there is a problem with the key' do
        allow(mock_redis).to receive(:pttl).with('harvester.throttle.google.com') { -1 }
        expect(mock_redis).to receive(:pexpire).with('harvester.throttle.google.com', 2000)
        request.acquire_lock {}
      end
    end
  end

  describe '#delay' do
    it 'returns the delay in ms when it matches the host' do
      request = described_class.new('http://google.com', 60_000, [{ host: 'google.com', delay: 5 }])
      expect(request.delay).to eq 5000
    end

    it "returns 0 when the URL doesn't match the host" do
      request = described_class.new('http://google.com', 60_000, [{ host: 'yahoo.com', delay: 5 }])
      expect(request.delay).to eq 0
    end
  end

  describe '#request_url' do
    it 'should request the url with the given timeout' do
      expect(RestClient::Request).to receive(:execute).with(method: :get,
                                                            url: 'http://google.com',
                                                            timeout: 60_000,
                                                            headers: { 'x-api-key' => 'key',
                                                                       'Authorization' => 'tokentokentoken' },
                                                            proxy: nil)
      request_obj = described_class.new('http://google.com', 60_000, [{ host: 'google.com', delay: 5 }],
                                        'x-api-key' => 'key', 'Authorization' => 'tokentokentoken')
      request_obj.request_url
    end
  end

  describe 'request_resource' do
    it 'should request the resource and return it' do
      expect(request).to receive(:request_url) { 'body' }
      expect(request.request_resource).to eq 'body'
    end
  end
end
