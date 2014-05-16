# The Supplejack code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack_core 

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