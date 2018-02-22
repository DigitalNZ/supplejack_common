

require "spec_helper"

describe SupplejackCommon::Request do
  let!(:klass) { SupplejackCommon::Request }
  let!(:request) { klass.new('http://google.com/titles/1', 10000) }

  before(:each) do
    RestClient::Request.stub(:execute) { 'body' }
  end

  describe ".get" do
    before(:each) do
      klass.stub(:new) { request }
    end

    it "initializes a request object" do
      klass.should_receive(:new).with("google.com",nil, [{delay: 1}], {}) { request }
      klass.get("google.com", nil,[{delay: 1}])
    end

    it "should fetch the resource and returns it" do
      request.should_receive(:get) { "body" }
      klass.get("google.com", nil).should eq "body"
    end

    it "should set the request_timeout" do
      request.request_timeout.should eq 10000
    end
  end

  describe "#initialize" do
    it "converts the array of throttling options to a hash" do
      request = klass.new("google.com",60000, [{host: "google.com", delay: 5}, {host: "yahoo.com", delay: 10}])
      request.throttling_options.should eq({"google.com" => 5, "yahoo.com" => 10})
    end

    it "handles nil options" do
      request = klass.new("google.com", nil)
      request.throttling_options.should eq({})
    end

    it "URI escapes the url" do
      request = klass.new("google.com/ben ten", nil)
      request.url.should eq "google.com/ben%20ten"
    end

    it 'can be initialized with headers' do
      headers = { 'x-api-key': 'API_KEY', 'Authorization': 'tokentokentoken' }

      request = klass.new('', '', [], headers)
      request.headers.should eq headers
    end
  end

  describe "#uri" do
    it "should initialize a URI from the url" do
      request.uri.should eq URI.parse("http://google.com/titles/1")
    end
  end

  describe "#host" do
    it "returns the request url host" do
      klass.new("http://gdata.youtube.com/feeds/api/videos?author=archivesnz&orderby=published", 60000).host.should eq "gdata.youtube.com"
    end
  end

  describe "get" do
    let!(:time) { Time.now }

    before(:each) do
      Time.stub(:now) { time }
    end

    it "should aquire the lock" do
      request.should_receive(:acquire_lock)
      request.get
    end

    it "should request the resource" do
      request.should_receive(:request_resource) { "body" }
      request.get.should eq "body"
    end
  end

  describe "#acquire_lock" do
    let(:mock_redis) { double(:redis).as_null_object }

    before do
      request.stub(:request_resource)
      SupplejackCommon.stub(:redis) { mock_redis }
      request.stub(:delay) { 2000 }
    end

    it "should set a key of host in redis" do
      mock_redis.should_receive(:setnx).with('harvester.throttle.google.com', 0)
      request.acquire_lock { }
    end

    it "should set the expiry of the key" do
      mock_redis.should_receive(:pexpire).with('harvester.throttle.google.com', 2000)
      request.acquire_lock { }
    end

    context "could not acquire lock" do
      before do
        mock_redis.stub(:setnx).and_return(false, true) # fails the first time, then succeeds
      end

      it "should sleep for the time left" do
        mock_redis.stub(:pttl).with('harvester.throttle.google.com') { 1234 }
        request.should_receive(:sleep).with(1.244)
        request.acquire_lock { }
      end

      it "should sleep for the whole delay is there is a problem with the key" do
        mock_redis.stub(:pttl).with('harvester.throttle.google.com') { -1 }
        mock_redis.should_receive(:pexpire).with('harvester.throttle.google.com', 2000)
        request.acquire_lock { }
      end
    end
  end

  describe "#delay" do
    it "returns the delay in ms when it matches the host" do
      request = klass.new("http://google.com", 60000, [{host: "google.com", delay: 5}])
      request.delay.should eq 5000
    end

    it "returns 0 when the URL doesn't match the host" do
      request = klass.new("http://google.com", 60000, [{host: "yahoo.com", delay: 5}])
      request.delay.should eq 0
    end
  end

  describe "#request_url" do
    it "should request the url with the given timeout" do
      RestClient::Request.should_receive(:execute).with(method: :get,
                                                        url: 'http://google.com',
                                                        timeout: 60_000,
                                                        headers: { 'x-api-key': 'key', 'Authorization': 'tokentokentoken'})
      request_obj = klass.new("http://google.com", 60000, [{host: "google.com", delay: 5}], { 'x-api-key': 'key', 'Authorization':'tokentokentoken'})
      request_obj.request_url
    end
  end

  describe "request_resource" do
    it "should request the resource and return it" do
      request.should_receive(:request_url) { "body" }
      request.request_resource.should eq "body"
    end
  end

end
