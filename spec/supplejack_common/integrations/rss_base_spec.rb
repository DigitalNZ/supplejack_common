# The Supplejack Common code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack 

require 'spec_helper'

require_relative 'parsers/rss_parser'

describe SupplejackCommon::Rss::Base do

  before(:all) do
    rss_xml = File.read(File.dirname(__FILE__) + "/source_data/rss_parser.xml")
    @document = Nokogiri.parse(rss_xml)
  end

  before do
    RssParser.stub(:index_document) { @document }
  end

  let!(:record) { RssParser.records.first }

  context "default values" do

    it "defaults the catefory to Newspapers" do
      record.category.should include("Newspapers")
    end

  end

  it "gets the record title" do
    record.title.should eq ["Cottrell murder accused initially treated as witness"]
  end

  it "gets the record description" do
    record.description.should eq ["One of two men charged with murdering Wellington journalist Phillip Cottrell was initially treated as a witness, a jury has heard."]
  end

  it "gets the record date" do
    record.date.should eq [Time.parse("2012-12-05 03:52:00 UTC")]
  end

  it "gets the record landing_url" do
    record.landing_url.should eq ["http://www.3news.co.nz/Cottrell-murder-accused-initially-treated-as-witness/tabid/423/articleID/279322/Default.aspx"]
  end

  it "gets the record thumbnail_url" do
    record.thumbnail_url.should eq ["http://cdn.3news.co.nz/3news/AM/2012/12/5/279322/Manuel-Robinson-Nicho-Waipuka-1200.jpg?width=180"]
  end

  context "overriden methods" do

    it "generates a large_thumbnail_url from the thumbnail_url" do
      record.large_thumbnail_url.should eq ["http://cdn.3news.co.nz/3news/AM/2012/12/5/279322/Manuel-Robinson-Nicho-Waipuka-1200.jpg?width=520"]
    end

    it "adds a Images values to the category" do
      record.category.should eq ["Newspapers", "Images"]
    end

  end
end