require "spec_helper"

describe DnzHarvester::Oai::RecordsContainer do

  let(:new_record) { mock(:record, deleted?: false) }
  let(:deleted_record) { mock(:record, deleted?: true) }
  let(:klass) { DnzHarvester::Oai::RecordsContainer }
  
  describe "records" do
    it "returns all the additions and changes" do
      klass.new([new_record]).records.should eq [new_record]
    end

    it "doesn't return any deleted records" do
      klass.new([new_record, deleted_record]).records.should eq [new_record]
    end
  end

  describe "#deletions" do
    it "returns all deleted records" do
      klass.new([new_record, deleted_record]).deletions.should eq [deleted_record]
    end
  end
end