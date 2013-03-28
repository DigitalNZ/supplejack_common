require "spec_helper"

describe Repository::Record do
  
  let(:record) { Repository::Record.new }
  let!(:primary_source) { record.sources.build(dc_identifier: ["tap:1234"], priority: 0, relation: ["tap:12345"]) }
  let(:source) { record.sources.build(dc_identifier: ["tap:1234"], priority: 1) }

  describe "#primary" do
    it "returns the primary source" do
      record.primary.should eq primary_source
    end
  end

  describe "#tap_id" do
    it "should extract the tap_id from the dc_identifier" do
      record.tap_id.should eq 1234
    end

    it "should find the tap_id within multiple dc_identifiers" do
      primary_source.dc_identifier = ["other_id", "tap:1234"]
      record.tap_id.should eq 1234
    end
  end

  describe "#parent_tap_id" do
    it "should extract the tap_id from the relation" do
      record.parent_tap_id.should eq 12345
    end

    it "should return nil if there is no parent" do
      primary_source.relation = nil
      record.parent_tap_id.should eq nil
    end
  end
end