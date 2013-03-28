require "spec_helper"

class TestParser; def self._throttle; nil; end; end

describe HarvesterCore::TapuhiRelationshipsEnrichment do

	let(:klass) { HarvesterCore::TapuhiRelationshipsEnrichment }
	let(:record) { mock(:record, attributes: {}).as_null_object }
	let(:enrichment) { klass.new(:tapuhi_relationships, {}, record, TestParser )}

	describe "#set_attribute_values" do
		it "should include a source id of tapuhi_relationships" do
		  enrichment.set_attribute_values
			enrichment.attributes.should include(source_id: "tapuhi_relationships")
		end

		context "record has no parent" do
			it "should have no relationship authorities" do
			  enrichment.set_attribute_values
		  	enrichment.attributes.keys.should_not include(:authorities)
			end
		end

		context "record has 1 parent" do

			let(:parent_record) { mock(:record, parent_tap_id: nil, tap_id: 1234, title: "title", attributes: {})}

			before do
				record.stub(:parent_tap_id) { 1234 }
				enrichment.stub(:find_record).with(1234) { parent_record }
				enrichment.stub(:find_record).with(nil) { nil }
			end

			it "should have a collection_parent & collection_root" do
			  enrichment.set_attribute_values
			  enrichment.attributes[:authorities].should include({authority_id: 1234, name: "collection_parent", text: "title"})
			  enrichment.attributes[:authorities].should include({authority_id: 1234, name: "collection_root", text: "title"})
			end
		end

		context "record has many ancestors" do
			before(:each) do
			  ancestors = [	mock(:record, tap_id: 123, parent_tap_id: 1234, title: "parent", attributes: {}),
			  							mock(:record, tap_id: 1234, parent_tap_id: 12345, title: "mid", attributes: {}),
			  							mock(:record, tap_id: 12345, parent_tap_id: nil, title: "root", attributes: {})]

			  record.stub(:parent_tap_id) { 123 }
			  
			  ancestors.each do |record|
			  	enrichment.stub(:find_record).with(record.tap_id) { record }
			  end
			  
			  enrichment.stub(:find_record).with(nil) { nil }
			end

			it "should have collection parent, collection root & collection_mid" do
			  enrichment.set_attribute_values
			  enrichment.attributes[:authorities].should include({authority_id: 123, name: "collection_parent", text: "parent"})
			  enrichment.attributes[:authorities].should include({authority_id: 1234, name: "collection_mid", text: "mid"})
			  enrichment.attributes[:authorities].should include({authority_id: 12345, name: "collection_root", text: "root"})
			end
		end
	end
end