require "spec_helper"

describe HarvesterCore::Request do

  let!(:klass) { HarvesterCore::Request }
  let!(:request) { klass.new("google.com") }

  before(:each) do
    RestClient.stub(:get) { "body" }
  end

  describe ".get" do
    before(:each) do
      klass.stub(:new) { request }
    end

    it "initializes a request object" do
      klass.should_receive(:new).with("google.com", [{max_per_minute: 10}]) { request }
      klass.get("google.com", [{max_per_minute: 10}])
    end

    it "should fetch the resource and returns it" do
      request.should_receive(:get) { "body" }
      klass.get("google.com").should eq "body"
    end
  end

  describe "#initialize" do
    it "converts the array of throttling options to a hash" do
      request = klass.new("google.com", [{host: "google.com", max_per_minute: 5}, {host: "yahoo.com", max_per_minute: 10}])
      request.throttling_options.should eq({"google.com" => 5, "yahoo.com" => 10})
    end

    it "handles nil options" do
      request = klass.new("google.com", nil)
      request.throttling_options.should eq({})
    end
  end

  describe "#uri" do
    it "should initialize a URI from the url" do
      request.uri.should eq URI.parse("google.com")
    end
  end

  describe "#host" do
    it "returns the request url host" do
      klass.new("http://gdata.youtube.com/feeds/api/videos?author=archivesnz&orderby=published").host.should eq "gdata.youtube.com"
    end
  end

  describe "#increment_count!" do
    let!(:time) { Time.now }

    before(:each) do
      Time.stub(:now) { time }
      request.stub(:current_count) { 2 }
      request.stub(:start_time) { time }
    end

    it "increments the count for the host" do
      request.should_receive(:set_redis_values).with(time, 3)
      request.increment_count!
    end

    context "more than a minute has passed since start_time" do
      before(:each) do
        request.stub(:start_time) { time - 61.seconds }
      end

      it "resets the time and count" do
        request.should_receive(:set_redis_values).with(Time.now, 1)
        request.increment_count!
      end
    end

    context "start time is nil" do
      it "reset start time and count" do
        request.stub(:start_time) {nil}
        request.should_receive(:set_redis_values).with(time, 1)
        request.increment_count!
      end
    end
  end

  describe "#set_redis_values" do
    before(:each) do
      request.stub(:host) { "twitter.com" }
    end

    it "should store the count in redis" do
      HarvesterCore.redis.should_receive(:set).with("twitter.com", "{\"time\":#{Time.now.to_i},\"count\":1}")
      request.set_redis_values(Time.now, 1)
    end
  end

  describe "#get_redis_values" do
    before(:each) do
      request.stub(:host) { "twitter.com" }
    end

    it "retrieves values for the host" do
      HarvesterCore.redis.stub(:get).with("twitter.com") { "{\"time\":#{Time.now.to_i},\"count\":1}" }
      request.get_redis_values.should eq({"time" => Time.now.to_i, "count" => 1})
    end

    it "should return empty hash" do
      HarvesterCore.redis.stub(:get).with("twitter.com").and_return(nil)
      request.get_redis_values.should eq({})
    end
  end

  describe "#current_count" do
    before(:each) do
      request.stub(:get_redis_values) { {"time" => Time.now.to_i, "count" => 1} }
    end

    it "should return the count" do
      request.current_count.should eq 1
    end
  end

  describe "#start_time" do
    let!(:time) { Time.now }

    before(:each) do
      request.stub(:get_redis_values) { {"time" => time.to_i, "count" => 1} }
    end

    it "should return the start_time" do
      request.start_time.to_i.should eq time.to_i
    end

    it "should return nil" do
      request.stub(:get_redis_values) { {} }
      request.start_time.should be_nil
    end
  end

  describe "#max_requests_per_minute" do
    it "returns the max_per_minute when it matches the host" do
      request = klass.new("http://google.com", [{host: "google.com", max_per_minute: 5}])
      request.max_requests_per_minute.should eq 5
    end

    it "returns nil when the URL doesn't match the host" do
      request = klass.new("http://google.com", [{host: "yahoo.com", max_per_minute: 5}])
      request.max_requests_per_minute.should be_nil
    end
  end

  describe "#limit_exceeded?" do
    let(:request) { request = klass.new("http://google.com", [{host: "google.com", max_per_minute: 10}]) }

    context "count exceeds limit and is within time period" do
      before(:each) do
        request.stub(:start_time) { Time.now }
        request.stub(:current_count) { 10 }
      end

      it "should return true" do
        request.limit_exceeded?.should be_true
      end
    end

    context "time is not within time period" do
      it "should return false" do
        request.stub(:start_time) { Time.now - 61 }
        request.stub(:current_count) {10} 
        request.limit_exceeded?.should be_false
      end
    end

    context "is the first request" do
      it "should return false" do
        request.stub(:start_time) { nil }
        request.limit_exceeded?.should be_false
      end
    end
  end

  describe "get" do
    it "should request the resource" do
      request.should_receive(:request_resource) { "body" }
      request.get.should eq "body"
    end
    it "shold increment count for host" do
      request.should_receive(:increment_count!) 
      request.get 
    end
  end

  describe "request_resource" do
    it "should request the resource and return it" do
      RestClient.should_receive(:get).with("google.com") { "body" }
      request.request_resource.should eq "body"
    end
  end

end