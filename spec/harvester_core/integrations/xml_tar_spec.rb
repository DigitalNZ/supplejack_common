# encoding: utf-8

require 'spec_helper'

require_relative 'parsers/xml_tar_parser'

describe HarvesterCore::Xml::Base do

  before do

  end

  let!(:record) { XmlTarParser.records.first }

  context "default values" do

    it "defaults the collection to NZ On Screen" do
      record.content_partner.should eq ["NZ On Screen"]
    end
  end

  it "gets the title" do
    record.title.should eq ["Record 1"]
  end

end