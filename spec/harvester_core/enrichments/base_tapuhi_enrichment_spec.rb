require "spec_helper"

class TestParser; def self._throttle; nil; end; end

describe HarvesterCore::BaseTapuhiEnrichment do
  let(:klass) { HarvesterCore::BaseTapuhiEnrichment }
  let(:record) { mock(:record, attributes: {}).as_null_object }
  let(:enrichment) { klass.new(:tapuhi_base, {}, record, TestParser )}

  describe "#denormalise" do

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
          enrichment.send(:denormalise)
          enrichment.attributes[:authorities].should include({authority_id: "2234", name: "name_authority", role: "(Subject)", text: "Awesome Title"})
        end
      end

      context "record has no authorities" do
        before do
          source.stub_chain(:[],:to_a) { [] }
          enrichment.stub(:primary) { source }
        end

        it "should have no relationship authorities" do
          enrichment.send(:denormalise)
          enrichment.attributes.keys.should_not include(:authorities)
        end
      end
    end
  end
end