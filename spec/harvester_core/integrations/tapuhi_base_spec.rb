# The Supplejack code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack_core 

require 'spec_helper'

require_relative 'parsers/tapuhi_parser'

describe HarvesterCore::Tapuhi::Base do

  before do
    TapuhiParser._base_urls[TapuhiParser.identifier] = [File.dirname(__FILE__) + "/source_data/tapuhi_source.tap"]
    TapuhiParser.run_length_bytes 8
  end

  let!(:record) { TapuhiParser.records(limit: 1).to_a.first }

  context "default values" do

    it "defaults the content_partner to Alexander Turnbull Library" do
      record.content_partner.should eq ["Alexander Turnbull Library"]
    end

  end

  it "gets the title from field_num 3" do
    record.title.should eq ["Ngati Maru (Tainui)"]
  end

  it "gets the dc_type from field_num 2" do
    record.dc_type.should eq ["IWI"]
  end

end