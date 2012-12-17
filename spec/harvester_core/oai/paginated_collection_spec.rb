require "spec_helper"

describe HarvesterCore::Oai::PaginatedCollection do

  class TestSource < HarvesterCore::Oai::Base; end

  let(:client) { mock(:client) }
  let(:options) { {} }
  let(:klass) { mock(:klass) }
  let(:record) { mock(:record).as_null_object }

  it "initializes the client, options and klass" do
    collection = HarvesterCore::Oai::PaginatedCollection.new(client, options, klass)
    collection.client.should eq client
    collection.options.should eq options
    collection.klass.should eq klass
  end

  it "initializes the limit" do
    HarvesterCore::Oai::PaginatedCollection.new(client, {limit: 10}, klass).limit.should eq 10
  end

  describe "#each" do
    let(:collection) { HarvesterCore::Oai::PaginatedCollection.new(client, {}, TestSource) }

    before do
      collection.stub(:client) { mock(:client, list_records: [record, record] ) }
    end

    it "stops iterating when the limit is reached" do
      collection.stub(:limit) { 1 }
      collection.each {|r| r}.size.should eq 1
    end

    it "initializes a new TestSource record for every oai record" do
      TestSource.should_receive(:new).twice
      collection.each {|r| r}
    end

    it "returns a array of TestSource records" do
      records = collection.each {|r| r}
      records.first.should be_a(TestSource)
    end
  end
end