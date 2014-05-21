# The Supplejack Common code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack 

require 'spec_helper'

require_relative 'parsers/oai_parser'

describe SupplejackCommon::Oai::Base do

  context "normal records" do

    before do
      body = File.read(File.dirname(__FILE__) + "/source_data/oai_library.xml")
      stub_request(:get, "http://library.org/?metadataPrefix=oai_dc&verb=ListRecords").to_return(:status => 200, :body => body)

      OAI::Client.any_instance.stub(:strip_invalid_utf_8_chars).with(body).and_return(body)
    end

    let!(:record) { OaiParser.records.first }

    context "default values" do

      it "defaults the category to Research papers" do
        record.category.should eq ["Research papers"]
      end

    end

    it "gets the record title" do
      record.title.should eq ["Selected resonant converters for IPT power supplies"]
    end

    it "gets the record identifier" do
      record.identifier.should eq ["oai:researchspace.auckland.ac.nz:2292/3"]
    end

    context "overriden methods" do

      it "generates a enrichment_url from the identifier" do
        record.enrichment_url.should eq ["https://researchspace.auckland.ac.nz/handle/2292/3?show=full"]
      end

    end
  end

  context "incremental harvest" do

    before do
      body = File.read(File.dirname(__FILE__) + "/source_data/oai_library_inc.xml")
      stub_request(:get, "http://library.org/?metadataPrefix=oai_dc&verb=ListRecords&from=2012-11-10").to_return(:status => 200, :body => body)

      OAI::Client.any_instance.stub(:strip_invalid_utf_8_chars).with(body).and_return(body)
    end

    context "changed records" do
      let!(:record) { OaiParser.records(from: Date.parse('2012-11-10')).first }

      it "gets the record title" do
        record.title.should eq ["Natural Algorithms"]
      end
      
    end

  end
end
