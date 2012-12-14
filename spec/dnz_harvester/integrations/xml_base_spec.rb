# encoding: utf-8

require 'spec_helper'

require_relative 'parsers/xml_parser'

describe DnzHarvester::Xml::Base do

  before do
    urls_xml = File.read("spec/dnz_harvester/integrations/source_data/xml_parser_urls.xml")
    stub_request(:get, "http://www.nzonscreen.com/api/title/").to_return(:status => 200, :body => urls_xml)

    record_xml = File.read("spec/dnz_harvester/integrations/source_data/xml_parser_record.xml")
    stub_request(:get, "http://www.nzonscreen.com/api/title/weekly-review-no-395-1949").to_return(:status => 200, :body => record_xml)
  end

  let!(:record) { XmlParser.records.first }

  context "default values" do

    it "defaults the collection to NZ On Screen" do
      record.content_partner.should eq ["NZ On Screen"]
    end

    it "defaults the category to Videos" do
      record.category.should eq ["Videos"]
    end

  end

  it "gets the title" do
    record.title.should eq ["Weekly Review No. 395"]
  end

  it "gets the record description" do
    record.description.should eq ["This Weekly Review features: An interview with Sir Peter Buck in which Te Rangi Hīroa (then Medical Officer of Health for Maori) explains the sabbatical he took to research Polynesian anthropology"]
  end

  it "gets the date" do
    record.date.should eq ["13:00:00, 29/01/2009"]
  end

  it "gets the tag" do
    record.tag.should eq ["te rangi hīroa", "public health", "māori health", "scenery"]
  end

  it "gets the thumbnail_url" do
    record.thumbnail_url.should eq ["http://www.nzonscreen.com/content/images/0000/3114/weekly-review-395.jpg"]
  end

  context "overriden methods" do

    it "gets the contributor" do
      record.contributor.should eq ["Stanhope Andrews"]
    end

  end
end