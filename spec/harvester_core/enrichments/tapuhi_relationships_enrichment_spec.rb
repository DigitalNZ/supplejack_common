require "spec_helper"

class TestParser; def self._throttle; nil; end; end

describe HarvesterCore::TapuhiRelationshipsEnrichment do

	let(:klass) { HarvesterCore::TapuhiRelationshipsEnrichment }
	let(:record) { mock(:record, attributes: {}).as_null_object }
	let(:enrichment) { klass.new(:tapuhi_relationships, {}, record, TestParser )}

	describe "#set_attribute_values" do

		context "record has no parent" do
			it "should have no relationship authorities" do
			  enrichment.set_attribute_values
		  	enrichment.attributes.keys.should_not include(:authorities)
			end
		end

		context "records parent is the root of the tree" do

			let(:parent_record) { mock(:record, parent_tap_id: nil, tap_id: 1234, title: "title", shelf_location: "ms-1234-d", attributes: {})}

			before do
				record.stub(:parent_tap_id) { 1234 }
				enrichment.stub(:find_record).with(1234) { parent_record }
				enrichment.stub(:find_record).with(nil) { nil }
				enrichment.set_attribute_values
			end

			it "should have a collection_parent & collection_root" do
			  enrichment.attributes[:authorities].should include({authority_id: 1234, name: "collection_parent", text: "title"})
			  enrichment.attributes[:authorities].should include({authority_id: 1234, name: "collection_root", text: "title"})
			end

			it "should have a relation field that represents the collection_root" do
			  enrichment.attributes[:relation].should include("title")
			  enrichment.attributes[:relation].should include("ms-1234-d")
			end

			it "should have a is_part_of field that represents the collection_parent" do
			  enrichment.attributes[:is_part_of].should include("title")
			  enrichment.attributes[:is_part_of].should include("ms-1234-d")
			end
		end

		context "record has many ancestors" do
			before(:each) do
			  ancestors = [	mock(:record, tap_id: 123, parent_tap_id: 1234, title: "parent", shelf_location:"def-456", attributes: {}),
			  							mock(:record, tap_id: 1234, parent_tap_id: 12345, title: "mid", attributes: {}).as_null_object,
			  							mock(:record, tap_id: 12345, parent_tap_id: nil, title: "root", shelf_location:"abc-123", attributes: {})]

			  record.stub(:parent_tap_id) { 123 }
			  
			  ancestors.each do |record|
			  	enrichment.stub(:find_record).with(record.tap_id) { record }
			  end
			  
			  enrichment.stub(:find_record).with(nil) { nil }
			  enrichment.set_attribute_values
			end

			it "should have collection parent, collection root & collection_mid" do
			  enrichment.attributes[:authorities].should include({authority_id: 123, name: "collection_parent", text: "parent"})
			  enrichment.attributes[:authorities].should include({authority_id: 1234, name: "collection_mid", text: "mid"})
			  enrichment.attributes[:authorities].should include({authority_id: 12345, name: "collection_root", text: "root"})
			end

			it "should have a relation field that represents the collection_root" do
			  enrichment.attributes[:relation].should include("root")
			  enrichment.attributes[:relation].should include("abc-123")
			end

			it "should have a is_part_of field that represents the collection_parent" do
			  enrichment.attributes[:is_part_of].should include("parent")
			  enrichment.attributes[:is_part_of].should include("def-456")
			end
		end
	end
end