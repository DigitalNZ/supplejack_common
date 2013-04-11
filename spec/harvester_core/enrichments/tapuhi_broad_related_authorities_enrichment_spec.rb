require "spec_helper"

class TestParser; def self._throttle; nil; end; end

describe HarvesterCore::TapuhiBroadRelatedAuthoritiesEnrichment do

  let(:klass) { HarvesterCore::TapuhiBroadRelatedAuthoritiesEnrichment }
  let(:record) { mock(:record, attributes: {}).as_null_object }
  let(:enrichment) { klass.new(:broad_related, {}, record, TestParser )}

  before(:each) do
    record.stub(:authority_taps) { [] }
  end

  describe "#set_attribute_values" do

    context "record has no authorities" do
      it "should not create any broad_related_authorities" do
        enrichment.set_attribute_values
        enrichment.attributes[:authorities].should be_nil
      end
    end

    context "record has authorities" do
      let (:name_authority) {mock(:record)}

      before(:each) do
        record.stub(:authority_taps).with(:name_authority) { [1] }
        enrichment.stub(:find_record).with(1) {name_authority}
      end

      it "should not create any broad_related_authorities if authority has no relationships" do
        name_authority.stub(:authorities) { [] }

        enrichment.set_attribute_values
        enrichment.attributes[:authorities].should be_nil
      end

      it "should create a broad_related_authority for each broader_term" do
        name_authority.stub(:authorities) { [ mock(:authority, authority_id: 2, name: "broader_term", text: "broad term"),
                                              mock(:authority, authority_id: 3, name: "broader_term", text: "broad term 2")] }

        enrichment.set_attribute_values
        enrichment.attributes[:authorities].should include({authority_id: 2, name: "broad_related_authority", text: "broad term"})
        enrichment.attributes[:authorities].should include({authority_id: 3, name: "broad_related_authority", text: "broad term 2"})
      end

      it "should create a broad_related_authority on the record for each broad_related_authority on the authority" do
        name_authority.stub(:authorities) { [ mock(:authority, authority_id: 2, name: "broad_related_authority", text: "broad related"),
                                              mock(:authority, authority_id: 3, name: "broad_related_authority", text: "broad related 2")] }

        enrichment.set_attribute_values
        enrichment.attributes[:authorities].should include({authority_id: 2, name: "broad_related_authority", text: "broad related"})
        enrichment.attributes[:authorities].should include({authority_id: 3, name: "broad_related_authority", text: "broad related 2"})
      end

      it "should remove duplicate authorities" do
        name_authority.stub(:authorities) { [ mock(:authority, authority_id: 2, name: "broad_related_authority", text: "broad related")] }
        record.stub(:authority_taps).with(:name_authority) { [1,2] }
        enrichment.stub(:find_record).with(2) {name_authority}

        enrichment.set_attribute_values
        enrichment.attributes[:authorities].count.should eq 1
        enrichment.attributes[:authorities].should include({authority_id: 2, name: "broad_related_authority", text: "broad related"})
      end
    end

  end
end