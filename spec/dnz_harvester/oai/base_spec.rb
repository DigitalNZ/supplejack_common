require 'spec_helper'

require_relative 'library'

describe DnzHarvester::Oai::Base do

  before do
    list_records_body = File.read(File.dirname(__FILE__) + "/library_list_records.xml")
    stub_request(:get, "http://library.org/?metadataPrefix=oai_dc&verb=ListRecords").
      to_return(:status => 200, :body => list_records_body, :headers => {})
  end

  let(:record) { Library.records.first }

  it "gets the record title" do
    record.title.should eq "Selected resonant converters"
  end
end