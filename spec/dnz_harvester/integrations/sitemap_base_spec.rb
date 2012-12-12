require 'spec_helper'

require_relative 'parsers/sitemap_parser'

describe DnzHarvester::Sitemap::Base do

  before do
    sitemap_path = File.dirname(__FILE__) + "/source_data/sitemap_parser_urls.xml"
    SitemapParser._base_urls[SitemapParser.identifier] = [sitemap_path]

    record_html = File.read(File.dirname(__FILE__) + "/source_data/sitemap_parser_record.html")
    stub_request(:get, "http://www.nzmuseums.co.nz/account/3700/object/145276/Attenhofer_A15_Swing_Jet_ski").to_return(:status => 200, :body => record_html)
  end

  let!(:record) { SitemapParser.records.first }

  context "default values" do

    it "defaults the collection to NZMuseums" do
      record.collection.should eq "NZMuseums"
    end

  end

  it "gets the title" do
    record.title.should eq "Attenhofer A15 'Swing Jet' ski."
  end

  it "gets the record description" do
    record.description.should eq "Attenhofer A15 'Swing Jet' ski. 195 cm. Attenhofer step-in release binding with RAMY brake."
  end

  it "gets the coverage" do
    record.coverage.should eq "Switzerland"
  end

  it "gets the placename" do
    record.placename.should eq "Switzerland"
  end

  it "gets the identifier" do
    record.identifier.should eq "MHC 00003"
  end

  it "gets the tags" do
    record.tags.should eq ["Coberger", "Skis"]
  end

  it "gets the license" do
    record.license.should eq "CC-BY"
  end

  it "gets the display_date" do
    record.display_date.should eq Time.utc(1970,1,1,12)
  end

  context "overriden methods" do

    it "returns Images when it has a thumbnail_url" do
      record.stub(:original_attributes) { {thumbnail_url: "http://google.com/imgage.png"} }
      record.category.should eq "Images"
    end

    it "returns Other without a thumbnail_url" do
      record.stub(:original_attributes) { {thumbnail_url: ""} }
      record.category.should eq "Other"
    end

    it "gets the thumbnail_url" do
      record.thumbnail_url.should eq "http://f1.ehive.com/3700/1/ua25q7_2h4j_s.jpg"
    end

  end
end
