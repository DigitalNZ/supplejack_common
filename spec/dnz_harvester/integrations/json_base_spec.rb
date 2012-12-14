# encoding: utf-8

require 'spec_helper'

require_relative 'parsers/json_parser'

describe DnzHarvester::Json::Base do

  before do
    json = File.read("spec/dnz_harvester/integrations/source_data/json_records.json")
    stub_request(:get, "http://api.europeana.eu/records.json").to_return(:status => 200, :body => json)
  end

  let!(:record) { JsonParser.records.first }

  context "default values" do

    it "defaults the collection to Europeana" do
      record.collection.should eq ["Europeana"]
    end

  end

  it "gets the title" do
    record.title.should eq ["Transactions and proceedings of the New Zealand Institute. Volume v.30 (1897)"]
  end

  it "gets the record description" do
    record.description.should eq ["New Zealand Institute"]
  end

  it "gets the creator" do
    record.creator.should eq ["New Zealand Institute (Wellington, N.Z"]
  end

  it "gets the language" do
    record.language.should eq ["mul"]
  end

  it "gets the dnz_type" do
    record.dnz_type.should eq ["TEXT"]
  end

  it "gets the contributing_partner" do
    record.contributing_partner.should eq ["NCSU Libraries (archive.org)"]
  end

  it "gets the thumbnail_url" do
    record.thumbnail_url.should eq ["http://bhl.ait.co.at/templates/bhle/sampledata/cachedImage.php?maxSize=200&filename=http://www.biodiversitylibrary.org/pagethumb/25449335"]
  end

  context "overriden methods" do

    it "gets the landing_url" do
      record.landing_url.should eq ["http://www.europeana.eu/portal/record/08701/533BD2421E162B12D599BBCC3BF0BA3C516A8CFB"]
    end

  end
end