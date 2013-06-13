# encoding: utf-8

require 'spec_helper'

require_relative 'parsers/xml_parser'

describe HarvesterCore::Xml::Base do

  before do
    xml = File.read("spec/harvester_core/integrations/source_data/xml_parser_records.xml")
    stub_request(:get, "http://digitalnz.org/xml").to_return(:status => 200, :body => xml)
  end

  let!(:record) { XmlParser.records.first }

  context "default values" do

    it "defaults the collection to NZ On Screen" do
      record.content_partner.should eq ["NZ On Screen"]
    end
  end

  it "gets the title" do
    record.title.should eq ["Page 4 Advertisements Column 4 (Otago Daily Times, 02 April 1888)"]
  end

  it "gets the record description" do
    record.description.should eq ["A thing"]
  end

  it "gets the date" do
    record.date.should eq ["2011-02-13 14:09:03 +1300"]
  end  

  it "gets the display_date using fetch" do
    record.display_date.should eq ["2011-02-13 14:09:03 +1300"]
  end

  it "gets the author" do
    record.author.should eq ["Andy"]
  end
end