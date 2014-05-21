# The Supplejack Common code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack_core 

require "spec_helper"

class TestParser; def self._throttle; nil; end; end

describe SupplejackCommon::TapuhiRecordsEnrichment do

  let(:klass) { SupplejackCommon::TapuhiRecordsEnrichment }
  let(:record) { mock(:record, id: '123', attributes: {}).as_null_object }
  let(:enrichment) { klass.new(:tapuhi_records_enrichment, {}, record, TestParser)}

  before(:each) do
    record.stub(:authority_taps) { [] }
  end

  describe "#set_attribute_values" do
    it "should denormalise relationships" do
      enrichment.should_receive(:denormalise)
      enrichment.set_attribute_values
    end

    it "should build format" do
      enrichment.should_receive(:build_format)
      enrichment.set_attribute_values
    end

    it "should build subject" do
      enrichment.should_receive(:build_subject)
      enrichment.set_attribute_values
    end

    it "should build creator" do
      enrichment.should_receive(:build_creator)
      enrichment.set_attribute_values
    end

    it "should build contributor" do
      enrichment.should_receive(:build_contributor)
      enrichment.set_attribute_values
    end

    it "should build relationships" do
      enrichment.should_receive(:relationships)
      enrichment.set_attribute_values
    end

    it "should build the collection title" do
      enrichment.should_receive(:build_collection_title)
      enrichment.set_attribute_values
    end

    it "should add broad_related_authorities" do
      enrichment.should_receive(:broad_related_authorities)
      enrichment.set_attribute_values
    end

    it "should build denormalize the locations" do
      enrichment.should_receive(:denormalize_locations)
      enrichment.set_attribute_values
    end
  end

  describe "#build_format" do
    let(:authorities) {
      [
        {authority_id: "2234", name: "recordtype_authority", role: "", text: "Bill" },
        {authority_id: "2235", name: "recordtype_authority", role: "", text: "Ben" },
        {authority_id: "2236", name: "name_authority", role: "", text: "Andy" }
      ]
    }

    it "adds all the record type authorities text fields to attributes[:format]" do
      enrichment.attributes[:authorities] = Set.new(authorities)
      enrichment.send(:build_format)
      enrichment.attributes[:format].should include("Bill")
      enrichment.attributes[:format].should include("Ben")
      enrichment.attributes[:format].should_not include("Andy")
    end
  end

  describe "#build_subject" do
    let(:authorities) {
      [
        {authority_id: "2235", name: "subject_authority", role: "", text: "Ben" },
        {authority_id: "2236", name: "subject_authority", role: "", text: "Bob" },
        {authority_id: "2237", name: "name_authority", role: "", text: "Andy" },
        {authority_id: "2238", name: "name_authority", role: "(Subject)", text: "Greg" },
        {authority_id: "2238", name: "name_authority", role: "(as a related subject)", text: "John" },
        {authority_id: "2239", name: "place_authority", role: "", text: "Kiwiland" },
        {authority_id: "2240", name: "subject_authority", role: "", text: "Joe - Jim" },
        {authority_id: "2241", name: "iwihapu_authority", role: "", text: "Ngati Poe" }
      ]
    }

    before { enrichment.attributes[:authorities] = Set.new(authorities) }

    it "should store all the subject_authorities text fields" do
      enrichment.send(:build_subject)
      enrichment.attributes[:subject].should include("Ben")
      enrichment.attributes[:subject].should include("Bob")
      enrichment.attributes[:subject].should_not include("Andy")
    end

    it "should store all the name_authorities with the role '(subject)'" do
      enrichment.send(:build_subject)
      enrichment.attributes[:subject].should include("Greg")
    end

    it "should store all the name_authorities with the role '(as a related subject)'" do
      enrichment.send(:build_subject)
      enrichment.attributes[:subject].should include("John")
    end

    it "should store all the place_authorities text fields" do
      enrichment.send(:build_subject)
      enrichment.attributes[:subject].should include("Kiwiland")
    end

    it "should store all the iwi hapu authorities" do
      enrichment.send(:build_subject)
      enrichment.attributes[:subject].should include("Ngati Poe")
    end

    it "should tokenize values that contain ' - '" do
      enrichment.send(:build_subject)
      enrichment.attributes[:subject].should include("Joe")
      enrichment.attributes[:subject].should include("Jim")
      enrichment.attributes[:subject].should_not include("Joe - Jim")
    end
  end

  describe "#denormalize_locations" do
      let(:authorities) {
        [
          {authority_id: "2235", name: "place_authority", role: "", text: "Wellington" },
          {authority_id: "2236", name: "place_authority", role: "", text: "Auckland" },
          {authority_id: "2237", name: "subject_authority", role: "", text: "Bob" }
        ]
      }

      let(:wellington_place_authority) { 
        mock(:record, id: 2235, locations: [
          mock(:location, attributes: {lat: 1, lng: 1, country: "New Zealand", placename: "Wellington", path: "Wellington, New Zealand"}.stringify_keys)
        ])
      }

      let(:auckland_place_authority) { 
        mock(:record, id: 2235, locations: [
          mock(:location, attributes: {lat: 2, lng: 2, country: "New Zealand", placename: "Auckland", path: "Auckland, New Zealand"}.stringify_keys)
        ])
      }

      before do
        record.stub(:authorities) { authorities }
        enrichment.stub(:find_record).with("2235") { wellington_place_authority }
        enrichment.stub(:find_record).with("2236") { auckland_place_authority }
      end

      it "should add the wellington & auckland location to the record from the place authority" do
        enrichment.send(:denormalize_locations)
        enrichment.attributes[:locations].should include({"lat" => 1, "lng" => 1, "country" => "New Zealand", "placename" => "Wellington", "path" => "Wellington, New Zealand"})
        enrichment.attributes[:locations].should include({"lat" => 2, "lng" => 2, "country" => "New Zealand", "placename" => "Auckland", "path" => "Auckland, New Zealand"})
        enrichment.attributes[:locations].count.should eq 2
      end
  end

  describe "#build_collection_title" do
    it "adds the library_collections to collection title" do
      enrichment.attributes[:library_collection] = Set.new(["Bill", "Bob"])
      enrichment.send(:build_collection_title)

      enrichment.attributes[:collection_title].should include("Bill")
      enrichment.attributes[:collection_title].should include("Bob")
    end

    it "adds the title of the relation field" do
      enrichment.attributes[:relation] = Set.new(["root_title","shelf_location"])
      enrichment.send(:build_collection_title)

      enrichment.attributes[:collection_title].should include("root_title")
    end

    it "adds the title of the is_part_of field" do
      enrichment.attributes[:is_part_of] = Set.new(["parent_title","shelf_location"])
      enrichment.send(:build_collection_title)

      enrichment.attributes[:collection_title].should include("parent_title")
    end

    it "should not include 'New Zealand Cartoon Archive'" do
      enrichment.send(:build_collection_title)
      enrichment.attributes[:collection_title].should_not include("New Zealand Cartoon Archive")
    end

    context "cartoon archive" do
      before do
        enrichment.stub(:cartoon_archive?) { true }
        enrichment.primary.stub(:[],:collection_title) { ['Collection'] }
      end

      it "adds 'New Zealand Cartoon Archive' to collection title" do
        enrichment.send(:build_collection_title)
        enrichment.attributes[:collection_title].should include("New Zealand Cartoon Archive")
      end

      context "primary fragment's collection title already contains 'New Zealand Cartoon Archive'" do
        before do
          enrichment.primary.stub(:[],:collection_title) { ['New Zealand Cartoon Archive'] }
        end

        it "does not add 'New Zealand Cartoon Archive' to collection title" do
          enrichment.send(:build_collection_title)
          enrichment.attributes[:collection_title].should_not include("New Zealand Cartoon Archive")
        end
      end
    end
  end

  describe "#build_creator" do
    context "has name_authorities" do
      let(:authorities) {
        [
          {authority_id: "2234", name: "name_authority", role: "(Creator)", text: "Bill" },
          {authority_id: "2235", name: "name_authority", role: "(Artist)", text: "Ben" },
          {authority_id: "2235", name: "name_authority", role: "(Subject)", text: "Billy" },
          {authority_id: "2237", name: "name_authority", role: "(as a related subject)", text: "John" },
          {authority_id: "2237", name: "name_authority", role: "(Contributor)", text: "Frank" },
          {authority_id: "2236", name: "subject_authority", role: "", text: "Andy" }
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

      it "should not include name authorities that are subjects or related subjects." do
        enrichment.attributes[:creator].should_not include("Billy")
        enrichment.attributes[:creator].should_not include("John")
      end

      it "should not include name authorities that are contributors" do
        enrichment.attributes[:creator].should_not include("Frank")
      end
    end

    context "has no name_authorities" do
      let(:authorities) {[
          {authority_id: "2236", name: "subject_authority", role: "", text: "Andy" },
          {authority_id: "2230", name: "subject_authority", role: "", text: "Ben" }
      ]}

      before do
        enrichment.attributes[:authorities] = authorities
        enrichment.send(:build_creator)
      end

      it "the creator should be set to 'Not specified'" do
        enrichment.attributes[:creator].should eq Set.new(["Not specified"])
      end
    end

  end

  describe "#build_contributor" do
    let(:authorities) {
      [
        {authority_id: "2234", name: "name_authority", role: "(Creator)", text: "Bill" },
        {authority_id: "2237", name: "name_authority", role: "(Contributor)", text: "Frank" },
        {authority_id: "2236", name: "subject_authority", role: "", text: "Andy" }
      ]
    }

    before do
      enrichment.attributes[:authorities] = authorities
      enrichment.send(:build_contributor)
    end

    it "should add contributors for name_authorities with role of contributor" do
      enrichment.attributes[:contributor].should eq Set.new(["Frank"])
    end
  end

  describe "#relationships" do
    context "record has no parent" do
      it "should have no relationship authorities" do
        enrichment.send(:relationships)
        enrichment.attributes.keys.should_not include(:authorities)
        enrichment.attributes.keys.should_not include(:relation)
        enrichment.attributes.keys.should_not include(:is_part_of)
        enrichment.attributes.keys.should_not include(:library_collection)
      end
    end

    context "records parent is the root of the tree" do

      let(:parent_record) { mock(:record, id: 123, parent_tap_id: nil, tap_id: 1234, title: "title", shelf_location: "ms-1234-d", attributes: {})}

      before do
        record.stub(:parent_tap_id) { 1234 }
        enrichment.stub(:find_record).with(1234) { parent_record }
        enrichment.stub(:find_record).with(nil) { nil }
      end

      context "library_collection found" do
        before do
          enrichment.stub(:get_library_collection) { "Corelli Collection" }
          enrichment.send(:relationships)
        end

        it "should have a collection_parent & collection_root" do
          enrichment.attributes[:authorities].should include({authority_id: 1234, name: "collection_parent", text: "title"})
          enrichment.attributes[:authorities].should include({authority_id: 1234, name: "collection_root", text: "title"})
        end

        it "should set the relation field" do
          enrichment.attributes[:relation].should include("title")
          enrichment.attributes[:relation].should include("ms-1234-d")
        end

        it "should set the is_part_of field" do
          enrichment.attributes[:is_part_of].should include("title")
          enrichment.attributes[:is_part_of].should include("ms-1234-d")
        end

        it "should set the library_collection field" do
          enrichment.attributes[:library_collection].should include("Corelli Collection")
        end
      end

      context "library_collection not found" do
        before do 
          parent_record.stub(:get_library_collection) { nil } 
          enrichment.send(:relationships)
        end

        it "should not set the library_collection field" do
          enrichment.attributes.keys.should_not include(:library_collection)
        end
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

  describe "#get_library_collection" do
    context "it finds a collection" do
      it "returns Ranfurly Collection" do
        enrichment.send(:get_library_collection, "PAColl-5745-1").should eq "Ranfurly Collection"
      end

      it "returns Sir Donald McLean Papers" do
        enrichment.send(:get_library_collection, "MS-Group-1551").should eq "Sir Donald McLean Papers"
      end

      it "returns Corelli Collection" do
        enrichment.send(:get_library_collection,"MS-Papers-0606").should eq "Corelli Collection"
      end

      it "returns Bible Society in New Zealand Collection" do
        enrichment.send(:get_library_collection, "MS-Group-1776").should eq "Bible Society in New Zealand Collection"
      end

      it "returns Arthur Nelson Field Collection" do
        enrichment.send(:get_library_collection,"PA11-194").should eq "Arthur Nelson Field Collection"
      end      
    end

    context "collection not found" do
      it "returns nil" do
        enrichment.send(:get_library_collection,"unexisting shelf location").should be_nil
      end
    end
  end

  describe "#broad_related_authorities" do

    context "record has no authorities" do
      it "should not create any broad_related_authorities" do
        enrichment.send(:broad_related_authorities)
        enrichment.attributes[:authorities].should be_empty
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
        enrichment.attributes[:authorities].should be_empty
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

      it "should not create a broad_related_authority if the authorities have no text" do
        name_authority.stub(:authorities) { [ mock(:authority, authority_id: 2, name: "broad_related_authority", text: nil)] }

        enrichment.send(:broad_related_authorities)
        enrichment.attributes[:authorities].should_not include({authority_id: 2, name: "broad_related_authority", text: nil})
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

  describe "#build_relation" do

    let(:parent) { mock(:record, internal_identifier: "tap:1234").as_null_object }
    
    context "primary_fragment has no relation field set" do
      let(:record) { mock(:record, id: 123, relation: nil) }

      it "should set the tap_id in the enrichment if it does not exist on the primary fragment." do
        enrichment.send(:build_relation, parent).should include("tap:1234")
      end
    end

    context "primary_fragment has relation field set" do
      let(:record) { mock(:record, id: 123, relation: "tap:1234") }

      it "should set the tap_id in the enrichment if it does not exist on the primary fragment." do
        enrichment.send(:build_relation, parent).should_not include("tap:1234")
      end
    end
  end

  describe "#cartoon_archive?" do
    context "is a NZ Cartoon Archive" do
      before do
        enrichment.attributes[:authorities] = [{authority_id: "2235", name: "recordtype_authority", role: "", text: "Cartoons (Commentary)" }]
      end

      it "returns true if New Zealand Cartoon Archive" do
        enrichment.send(:cartoon_archive?).should be_true
      end
    end

    it "returns true if New Zealand Cartoon Archive" do
      enrichment.send(:cartoon_archive?).should be_false
    end
  end
end