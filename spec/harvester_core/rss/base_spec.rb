require 'spec_helper'

describe HarvesterCore::Rss::Base do

  let(:klass) { HarvesterCore::Rss::Base }

  describe ".attribute" do
    it "add a non standard element to feedzirra" do
      Feedzirra::Feed.should_receive(:add_common_feed_entry_element).with(:enclosure, {value: :url, with: {type: "image/jpeg"}})
      klass.attribute :thumbnail_url, from: :enclosure, value: :url, with: {type: "image/jpeg"}
    end

    it "doesn't add the element when it has a default value" do
      Feedzirra::Feed.should_not_receive(:add_common_feed_entry_element)
      klass.attribute :thumbnail_url, default: "http://google.com"
    end
  end

  describe ".records" do
    let(:entry) { mock(:entry).as_null_object }
    let(:feed) { mock(:feed, entries: [entry]) }

    it "initializes a new rss record for every rss entry" do
      klass.stub(:feeds) { {"goo.gle" => feed} }
      klass.should_receive(:new).once.with(entry)
      klass.records
    end
  end

  describe ".feeds" do
    it "retrieves the feeds using feedzirra" do
      klass.base_url "http://google.com"
      Feedzirra::Feed.should_receive(:fetch_and_parse).with(["http://google.com"])
      klass.feeds
    end
  end

  describe "#strategy_value" do
    let(:rss_entry) { mock(:rss_entry).as_null_object }
    let(:record) { klass.new(rss_entry) }

    it "calls the appropiate method on the rss_entry" do
      rss_entry.should_receive(:thumbnail) { "http://google.com" }
      record.strategy_value(from: :thumbnail).should eq "http://google.com"
    end

    it "returns nil when :from is not specified" do
      record.strategy_value(from: nil).should be_nil
    end

    it "returns nil when :from is not specified" do
      record.strategy_value(nil).should be_nil
    end
  end
end