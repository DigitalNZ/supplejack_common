require "spec_helper"

class TestParser; def self._throttle; nil; end; end

describe HarvesterCore::TapuhiDenormalizeEnrichment do

	let(:klass) { HarvesterCore::TapuhiDenormalizeEnrichment }
	let(:record) { mock(:record, attributes: {}).as_null_object }
	let(:enrichment) { klass.new(:tapuhi_denormalization, {}, record, TestParser )}

	describe "#set_attribute_values" do
		it "should set the source_id to tapuhi_denormalization " do
		  enrichment.set_attribute_values
			enrichment.attributes.should include(source_id: "tapuhi_denormalization")
		end

		context "has a record with a source" do
			let(:record) { mock(:record, title: "Awesome Title")}
			let(:source) { HarvesterCore::SourceWrap.new(mock(:source, attributes: {})) }

			context "record has authorities" do
				let(:authority) { {"authority_id" => "2234", "name" => "name_authority", "role" => "(Subject)" } }
		
				before do
					source.stub_chain(:[],:to_a) { [authority] }
					enrichment.stub(:primary) { source }
					enrichment.stub(:find_record).with("2234") { record }
				end

				it "should add the enriched authorities" do
				  enrichment.set_attribute_values
				  enrichment.attributes[:authorities].should include({authority_id: "2234", name: "name_authority", role: "(Subject)", text: "Awesome Title"})
				end
			end

			context "record has no authorities" do
				before do
					source.stub_chain(:[],:to_a) { [] }
					enrichment.stub(:primary) { source }
				end

				it "should have no relationship authorities" do
				  enrichment.set_attribute_values
			  	enrichment.attributes.keys.should_not include(:authorities)
				end
			end
		end
	end
end