require "spec_helper"

describe Repository::Record do
  
  let(:record) { Repository::Record.new }
  let!(:primary_source) { record.sources.build(dc_identifier: ["tap:1234"], priority: 0, is_part_of: ["tap:12345"], relation: ["tap:123456"], authorities: []) }
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
    it "should extract the tap_id from the is_part_of" do
      record.parent_tap_id.should eq 12345
    end

    it "should return relation if there is no is_part_of" do
      primary_source.is_part_of = nil
      record.parent_tap_id.should eq 123456
    end

    it "should return nil if there is no is_part_of or relation" do
      primary_source.is_part_of = nil
      primary_source.relation = nil
      record.parent_tap_id.should eq nil
    end
  end

  describe "#authority_taps" do
    it "should return the tap_id's of given authority_type" do
      primary_source.authorities.build(authority_id: 1, name: "name_authority", text: "name")
      primary_source.authorities.build(authority_id: 2, name: "place_authority", text: "place")

      record.authority_taps(:name_authority).should eq [1]
    end

    it "should return [] if there are no matching authorities" do
      primary_source.authorities = nil
      record.authority_taps(:name_authority).should eq []
    end
  end

  describe "#authorities" do
    let(:source2) { record.sources.build(priority: -1) }

    before(:each) do
      @auth1 = primary_source.authorities.build(authority_id: 1, name: 'name_authority', text: '')
      @auth2 = primary_source.authorities.build(authority_id: 2, name: 'name_authority', text: '')
      @auth3 = source2.authorities.build(authority_id: 2, name: 'name_authority', text: 'John Doe')
    end

    it "merges authorities based on priority" do
      record.authorities.count.should eq 2
      record.authorities.should include(@auth1)
      record.authorities.should include(@auth3)
    end
  end

  describe "#sorted_sources" do
    it "returns a list of sources sorted by priority" do
      record.sources.build(priority: 10)
      record.sources.build(priority: -1)
      record.sources.build(priority: 5)

      record.send(:sorted_sources).map(&:priority).should eq [-1,0,5,10] 
    end
  end
end