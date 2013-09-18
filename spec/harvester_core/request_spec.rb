require "spec_helper"

describe HarvesterCore::Request do

  let!(:klass) { HarvesterCore::Request }
  let!(:request) { klass.new("http://google.com/titles/1", 10000) }

  before(:each) do
    RestClient::Request.stub(:execute) { "body" }
  end

  describe ".get" do
    before(:each) do
      klass.stub(:new) { request }
    end

    it "initializes a request object" do
      klass.should_receive(:new).with("google.com",nil, [{delay: 1}]) { request }
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

    it "should request the resource" do
      request.should_receive(:request_resource) { "body" }
      request.get.should eq "body"
    end

    it "sleeps until the delay has passed" do
      request.stub(:seconds_to_wait) { 1 }
      request.should_receive(:sleep).with(1)
      request.get
    end

    it "should set the last_request_at" do
      request.should_receive("last_request_at=").with(time)
      request.get
    end
  end

  describe "#seconds_to_wait" do
    let!(:time) { Time.now }

    before(:each) do
      Time.stub(:now) { time }
    end

    it "returns the number of seconds needed to wait before the next request" do
      request.stub(:delay) { 3 }
      request.stub(:last_request_at) { time.to_f - 2 }
      request.seconds_to_wait.should eq 1
    end

    it "returns 0 when there should be no delay" do
      request.stub(:delay) { 3 }
      request.stub(:last_request_at) { time.to_i - 4 }
      request.seconds_to_wait.should eq 0
    end

    it "returns fractions of a second" do
      last_request_at = time.to_f - 2.5
      request.stub(:delay) { 3 }
      request.stub(:last_request_at) { last_request_at }
      request.seconds_to_wait.should eq 0.5
    end

    it "returns 0 when there is no last_request_at" do
      request.stub(:delay) { 3 }
      request.stub(:last_request_at) { 0.0 }
      request.seconds_to_wait.should eq 0
    end
  end

  context "get/set last_request_at" do
    let!(:time) { Time.now }

    describe "#last_request_at=" do
      it "stores the request time in redis" do
        HarvesterCore.redis.should_receive(:set).with("google.com", time.to_f)
        request.last_request_at = time
      end
    end

    describe "#last_request_at" do
      it "retrieves the last_request_at in seconds" do
        HarvesterCore.redis.stub(:get).with("google.com") { "12345678" }
        request.last_request_at.should eq 12345678
      end
    end
  end

  describe "#delay" do
    it "returns the delay when it matches the host" do
      request = klass.new("http://google.com", 60000, [{host: "google.com", delay: 5}])
      request.delay.should eq 5
    end

    it "returns 0 when the URL doesn't match the host" do
      request = klass.new("http://google.com", [{host: "yahoo.com", delay: 5}])
      request.delay.should eq 0
    end
  end

  describe "#request_url" do
    it "should request the url with the given timeout" do
      RestClient::Request.should_receive(:execute).with(method: :get, url: "http://google.com", timeout: 60000)
      request_obj = klass.new("http://google.com", 60000, [{host: "google.com", delay: 5}])
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