require "spec_helper"

describe DnzHarvester::RecordsContainer do
  
  let(:record) { mock(:record) }
  let(:klass) { DnzHarvester::RecordsContainer }
  
  describe "#initialize" do
    it "assigns the records" do
      klass.new([record]).records.should eq [record]
    end
  end

  describe "#deletions" do
    it "returns an empty array" do
      klass.new([record]).deletions.should eq []
    end
  end

  describe "#method_missing" do
    it "executes any method on the records array" do
      records = [record]
      container = klass.new(records)
      records.should_receive(:map) { records }
      container.map {|r| r}
    end
  end
end