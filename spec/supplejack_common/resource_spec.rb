require "spec_helper"

describe SupplejackCommon::Resource do

  let(:klass) { SupplejackCommon::Resource }
  let(:resource) { klass.new("http://google.com/1") }

  describe "#fetch_document" do
    let(:resource) { klass.new("http://google.com/1", {throttling_options: {host: "google.com", delay: 1}, http_headers: { 'x-api-key': 'key'} }) }

    it "request the resource with the throttling options, request timeout, and http_headers" do
      SupplejackCommon::Request.should_receive(:get).with("http://google.com/1", 60000, {host: "google.com", delay: 1}, { 'x-api-key': 'key'} )
      resource.send(:fetch_document)
    end
  end

  describe "#strategy_value" do
  	it "should throw a not implemented error" do
  		expect {resource.strategy_value({})}.to raise_error(NotImplementedError)
  	end
  end

  describe "#fetch" do
  	it "should throw a not implemented error" do
  		expect {resource.fetch("hi")}.to raise_error(NotImplementedError)
  	end
  end
end
