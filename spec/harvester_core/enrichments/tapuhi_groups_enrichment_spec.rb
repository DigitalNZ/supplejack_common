# The Supplejack code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack_core 

require "spec_helper"

class TestParser; def self._throttle; nil; end; end

describe HarvesterCore::TapuhiGroupsEnrichment do
  let(:klass) { HarvesterCore::TapuhiGroupsEnrichment }
  let(:record) { mock(:record, id: 1234, attributes: {}).as_null_object }
  let(:enrichment) { klass.new(:tapuhi_groups_enrichment, {priority: -10}, record, TestParser)}

  before(:each) do
    record.stub(:parent_tap_id) { nil }
  end

  describe "#set_attribute_values" do
    it "should enrich groups" do
      enrichment.should_receive(:enrich_groups)
      enrichment.set_attribute_values
    end
  end

  describe "#enrich_groups" do
    it "should not write a fragment for the current record" do
      enrichment.enrich_groups
      enrichment.record_attributes.keys.should_not include(record.id)
    end

    context "the record has a parent" do
      let(:parent_record) { mock(:record, id: '123a2', title: "parent_title")}
      before(:each) do
        record.stub(:parent_tap_id) { 123 }
        enrichment.stub(:find_record).with(123) {parent_record}
        enrichment.enrich_groups
      end

      it "should set the category to Group for parent" do
        enrichment.record_attributes["123a2"][:category].should eq Set.new(["Groups"])
      end

      it "should add the title or the parent to the parents collection_title" do
        enrichment.record_attributes["123a2"][:collection_title].should eq Set.new(["parent_title"])
      end

      it "should add a deletion for category => 'Other' on parent" do
        enrichment.record_attributes["123a2"][:deletion_list].first[:category].should eq Set.new(["Other"])
      end
    end
  end

  describe ".before" do
    it "should delete fragments with my source_id" do
      RestClient.should_receive(:delete).with("#{ENV["API_HOST"]}/harvester/fragments/tapuhi_groups_enrichment.json")
      klass.before(:tapuhi_groups_enrichment)
    end
  end

end