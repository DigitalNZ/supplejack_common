require "spec_helper"

describe DnzHarvester::PaginatedCollection do
  
  let(:record) { mock(:record) }
  let(:klass) { DnzHarvester::PaginatedCollection }
  
  describe "#initialize" do
    it "assigns the records" do
      klass.new([record]).records.should eq [record]
    end
  end

  describe "#method_missing" do
    it "executes any method on the records array" do
      records = [record]
      paginator = klass.new(records)
      records.should_receive(:map) { records }
      paginator.map {|r| r}
    end
  end
end