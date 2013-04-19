require "spec_helper"

class TestParser; def self._throttle; nil; end; end

describe HarvesterCore::TapuhiRecordsEnrichment do

  let(:klass) { HarvesterCore::TapuhiRecordsEnrichment }
  let(:record) { mock(:record, attributes: {}).as_null_object }
  let(:enrichment) { klass.new(:tapuhi_records_enrichment, {}, record, TestParser )}

  before(:each) do
    record.stub(:authority_taps) { [] }
  end

  describe "#set_attribute_values" do
    it "should denormalise relationships" do
      enrichment.should_receive(:denormalise)
      enrichment.set_attribute_values
    end

    it "should build creator" do
      enrichment.should_receive(:build_creator)
      enrichment.set_attribute_values
    end

    it "should build relationships" do
      enrichment.should_receive(:relationships)
      enrichment.set_attribute_values
    end

    it "should add broad_related_authorities" do
      enrichment.should_receive(:broad_related_authorities)
      enrichment.set_attribute_values
    end
  end

  describe "build_creator" do
    context "has name_authorities" do
      let(:authorities) {
        [
          {authority_id: "2234", name: "name_authority", role: "(Creator)", title: "Bill" },
          {authority_id: "2235", name: "name_authority", role: "(Artist)", title: "Ben" },
          {authority_id: "2236", name: "subject_authority", role: "", title: "Andy" }
        ]
      }

      before do
        enrichment.attributes[:authorities] = authorities
        enrichment.send(:build_creator)
      end

      it "@attributes should have a key creator" do
        enrichment.attributes.keys.should include(:creator)
      end

      it "should store the name authorities titles in the creator field." do
        enrichment.attributes[:creator].should include("Bill")
        enrichment.attributes[:creator].should include("Ben")
        enrichment.attributes[:creator].should_not include("Andy")
      end
    end

    context "has no name_authorities" do
      let(:authorities) {[
          {authority_id: "2236", name: "subject_authority", role: "", title: "Andy" },
          {authority_id: "2230", name: "subject_authority", role: "", title: "Ben" }
      ]}

      before do
        enrichment.attributes[:authorities] = authorities
        enrichment.send(:build_creator)
      end

      it "the creator should be set to 'Not specified'" do
        enrichment.attributes[:creator].should eq ["Not specified"]
      end
    end

  end

  describe "#relationships" do
    context "record has no parent" do
      it "should have no relationship authorities" do
        enrichment.send(:relationships)
        enrichment.attributes.keys.should_not include(:authorities)
        enrichment.attributes.keys.should_not include(:relation)
        enrichment.attributes.keys.should_not include(:is_part_of)
      end
    end

    context "records parent is the root of the tree" do

      let(:parent_record) { mock(:record, parent_tap_id: nil, tap_id: 1234, title: "title", shelf_location: "ms-1234-d", attributes: {})}

      before do
        record.stub(:parent_tap_id) { 1234 }
        enrichment.stub(:find_record).with(1234) { parent_record }
        enrichment.stub(:find_record).with(nil) { nil }
        enrichment.send(:relationships)
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
        ancestors = [ mock(:record, tap_id: 123, parent_tap_id: 1234, title: "parent", shelf_location:"def-456", attributes: {}),
                      mock(:record, tap_id: 1234, parent_tap_id: 12345, title: "mid", attributes: {}).as_null_object,
                      mock(:record, tap_id: 12345, parent_tap_id: nil, title: "root", shelf_location:"abc-123", attributes: {})]

        record.stub(:parent_tap_id) { 123 }
        
        ancestors.each do |record|
          enrichment.stub(:find_record).with(record.tap_id) { record }
        end
        
        enrichment.stub(:find_record).with(nil) { nil }
        enrichment.send(:relationships)
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

  describe "#broad_related_authorities" do

    context "record has no authorities" do
      it "should not create any broad_related_authorities" do
        enrichment.send(:broad_related_authorities)
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

        enrichment.send(:broad_related_authorities)
        enrichment.attributes[:authorities].should be_nil
      end

      it "should create a broad_related_authority for each broader_term" do
        name_authority.stub(:authorities) { [ mock(:authority, authority_id: 2, name: "broader_term", text: "broad term"),
                                              mock(:authority, authority_id: 3, name: "broader_term", text: "broad term 2")] }

        enrichment.send(:broad_related_authorities)
        enrichment.attributes[:authorities].should include({authority_id: 2, name: "broad_related_authority", text: "broad term"})
        enrichment.attributes[:authorities].should include({authority_id: 3, name: "broad_related_authority", text: "broad term 2"})
      end

      it "should create a broad_related_authority on the record for each broad_related_authority on the authority" do
        name_authority.stub(:authorities) { [ mock(:authority, authority_id: 2, name: "broad_related_authority", text: "broad related"),
                                              mock(:authority, authority_id: 3, name: "broad_related_authority", text: "broad related 2")] }

        enrichment.send(:broad_related_authorities)
        enrichment.attributes[:authorities].should include({authority_id: 2, name: "broad_related_authority", text: "broad related"})
        enrichment.attributes[:authorities].should include({authority_id: 3, name: "broad_related_authority", text: "broad related 2"})
      end

      it "should remove duplicate authorities" do
        name_authority.stub(:authorities) { [ mock(:authority, authority_id: 2, name: "broad_related_authority", text: "broad related")] }
        record.stub(:authority_taps).with(:name_authority) { [1,2] }
        enrichment.stub(:find_record).with(2) {name_authority}

        enrichment.send(:broad_related_authorities)
        enrichment.attributes[:authorities].count.should eq 1
        enrichment.attributes[:authorities].should include({authority_id: 2, name: "broad_related_authority", text: "broad related"})
      end
    end
  end
end