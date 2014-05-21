# encoding: ISO-8859-1

# The Supplejack Common code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack 

require "spec_helper"

describe SupplejackCommon::Tapuhi::Base do

  let(:klass) { SupplejackCommon::Tapuhi::Base }
  let(:record) { klass.new(source) }
  let(:source) { File.open(File.expand_path(".") + "/spec/supplejack_common/integrations/source_data/tapuhi_source.tap", 'r:iso-8859-1') {|f| f.read } }
  
  describe ".run_length_bytes" do
    it "stores the run length bytes" do
      klass.run_length_bytes 8
      klass._run_length_bytes[klass.identifier].should eq 8
    end
  end

  describe ".get_run_length_bytes" do
    it "gets the run_length_bytes" do
      klass.run_length_bytes 8
      klass.get_run_length_bytes.should eq 8
    end
  end

  describe "#initialize" do
    it "assigns the tapuhi source data" do
      record = klass.new(source)
      record.tapuhi_source.should eq source
    end

    it "initializes the record from a json array (raw)" do
      json = ["title", "date"].to_json
      record = klass.new(json, true)
      record.fields.should eq ["title", "date"]
    end
  end

  describe "#fields" do
    it "returns the parsed tapuhi source" do
      record.stub(:parse_tapuhi_source) { ["Source"] }
      record.fields.should eq ["Source"]
    end
  end

  describe "#parse_tapuhi_source" do
    it "parses the source into an array of fields" do
      record.parse_tapuhi_source.should eq [["1921"], ["0|Unclassified"], ["IWI"], ["Ngati Maru (Tainui)"], [], ["NIMTAII"], [], [], ["03501", "22801"], ["01103", "12201", "12301"], ["15 Nov 1991\\19:33:08"], ["20 Aug 2001\\14:49:09\\543733"], [], [], ["NGATI MARU TAINUI"], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], ["Situated between Thames and Whangamata down to the Ohinemuri river. (Reference  Leslie Kelly `Tainui')"], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], ["1"], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], ["19587"], ["53426", "482227", "482228", "973145"], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], ["M", "D", "P", "O"]]
    end
  end

  describe "#raw_data" do
    it "returns a hash of values with the position of the field as key" do
      record.stub(:fields) { [[], ["Title"], ["Date"], [], ["Subject"]] }
      record.raw_data.should eq({1 => ["Title"], 2 => ["Date"], 4 => ["Subject"]}.to_json)
    end
  end

  describe "#full_raw_data" do
    let(:fields) { [[], ["Title"], ["Date"], [], ["Subject"]] }

    it "should convert the raw data to json" do
      record.stub(:fields) { fields }
      record.full_raw_data.should eq fields.to_json
    end
  end

  describe "#fetch" do
    it "retrieves a value from the fields array" do
      record.stub(:fields) { [[], ["Title"], ["Date"], [], ["Subject"]] }
      record.fetch(2).to_a.should eq ["Date"]
    end
  end

  describe "#strategy_value" do
    it "should return the field at the requested position" do
      record.stub(:fields) { [[], ["Title"], ["Date"], [], ["Subject"]] }
      record.strategy_value(field_num: 2).should eq ["Date"]
    end

    it "should return nil if there is no field_num requested" do
      record.strategy_value().should eq nil
    end
  end
end