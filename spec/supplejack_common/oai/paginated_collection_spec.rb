# The Supplejack Common code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack_core 

require "spec_helper"

describe SupplejackCommon::Oai::PaginatedCollection do

  class TestSource < SupplejackCommon::Oai::Base; end

  let(:client) { mock(:client) }
  let(:options) { {} }
  let(:klass) { mock(:klass) }
  let(:record) { mock(:record).as_null_object }

  it "initializes the client, options and klass" do
    collection = SupplejackCommon::Oai::PaginatedCollection.new(client, options, klass)
    collection.client.should eq client
    collection.options.should eq options
    collection.klass.should eq klass
  end

  it "initializes the limit" do
    SupplejackCommon::Oai::PaginatedCollection.new(client, {limit: 10}, klass).limit.should eq 10
  end

  describe "#each" do
    let(:collection) { SupplejackCommon::Oai::PaginatedCollection.new(client, {}, TestSource) }

    before do
      list = mock(:list, full: [record, record])
      collection.stub(:client) { mock(:client, list_records: list ) }
    end

    it "stops iterating when the limit is reached" do
      collection.stub(:limit) { 1 }
      records = [] 
      collection.each {|r| records << r }
      records.size.should eq 1
    end

    it "initializes a new TestSource record for every oai record" do
      TestSource.should_receive(:new).twice { record }
      collection.each {|r| r}
    end

    it "returns a array of TestSource records" do
      records = []
      collection.each {|r| records << r }
      records.first.should be_a(TestSource)
    end
  end
end