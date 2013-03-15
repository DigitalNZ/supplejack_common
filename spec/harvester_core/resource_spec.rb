require "spec_helper"

describe HarvesterCore::Resource do

  let(:klass) { HarvesterCore::Resource }
  let(:resource) { klass.new("http://google.com/1") }
  
  describe "#fetch" do
    let(:resource) { klass.new("http://google.com/1", {throttling_options: {host: "google.com", delay: 1}}) }

    it "request the resource with the throttling options" do
      HarvesterCore::Request.should_receive(:get).with("http://google.com/1", {host: "google.com", delay: 1})
      resource.fetch
    end
  end
end