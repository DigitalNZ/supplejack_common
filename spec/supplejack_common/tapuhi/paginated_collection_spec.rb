# The Supplejack Common code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack_core 

# encoding: ISO-8859-1

require "spec_helper"

describe SupplejackCommon::Tapuhi::PaginatedCollection do

  class TestSourceTapuhi < SupplejackCommon::Tapuhi::Base
    run_length_bytes 8
  end

  let(:klass) { TestSourceTapuhi }
  let(:record) { mock(:record).as_null_object }
  let(:collection) { SupplejackCommon::Tapuhi::PaginatedCollection.new(TestSourceTapuhi, ["/path/to/file"], "10") }

  it "initializes the file_paths, klass and limit" do
    collection.klass.should eq TestSourceTapuhi
    collection.file_paths.should eq ["/path/to/file"]
    collection.limit.should eq 10
  end

  describe "#each" do
    let(:file) {  StringIO.new("0000015956\xFE0|Unclassified\xFETYP\xFEAdministrative records       Reports\xFE\xFEAERREPS\xFE\xFE\xFE04301\xFE\xFE09 Dec 1991\\12:03:44\xFE09 Dec 1991\\12:03:44\xFE\xFE\xFEADMINISTRATIVE RECORDS REPORTS00000173118\xFE0|Unclassified\xFETYP\xFEGeneral records              Conference Papers\xFE\xFEGLRCPAS\xFE\xFE\xFE04301\xFE\xFE09 Dec 1991\\12:03:45\xFE09 Dec 1991\\12:03:45\xFE\xFE\xFEGENERAL RECORDS CONFERENCE PAPERS", 'r:iso-8859-1') }

    before(:each) do
      File.stub(:open).and_yield( file )
    end

    it "opens the files in iso-8859-1 encoding" do
      File.should_receive(:open).with('/path/to/file','r:iso-8859-1') { file }
      collection.each {|r| r}
    end

    it "splits file into records by length" do
      records = []
      collection.each {|r| records << r}
      records.size.should eq 2
    end

    it "splits record into fields using \xFE seperator" do
      TestSourceTapuhi.should_receive(:new).twice { record }
      collection.each {|r| r}
    end

    it "stops returning records after limit" do
      collection.stub(:limit) { 1 }
      records = []
      collection.each {|r| records << r}
      records.size.should eq 1
    end
  end

end
