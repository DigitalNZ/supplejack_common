require "spec_helper"

class TestParser; def self._throttle; nil; end; end

describe HarvesterCore::TapuhiAuthoritiesEnrichment do

  let(:klass) { HarvesterCore::TapuhiAuthoritiesEnrichment }
  let(:record) { mock(:record, attributes: {}).as_null_object }
  let(:enrichment) { klass.new(:tapuhi_authorities, {}, record, TestParser )}

	describe "#set_attribute_values" do

    context "record has no broader_term" do
      it "should not create a broader_related_authority" do
        enrichment.set_attribute_values
        enrichment.attributes.keys.should_not include(:authorities)
      end
    end

    context "record has a broader_term with no further broader_terms" do
      let(:broader_parent) { mock(:record, title: 'title') }

      before(:each) do
        record.stub(:authority_taps).with(:broader_term) { [123] }
        enrichment.stub(:find_record).with(123) { broader_parent }
        enrichment.stub(:find_record).with(nil) { nil }
        broader_parent.stub(:authority_taps).with(:broader_term) { [] }
      end

      it "should not create a broader_related_authority" do
        enrichment.set_attribute_values
        enrichment.attributes.keys.should_not include(:authorities)
      end
    end

    context "record has several ancestors" do

      before(:each) do
        broader_ancestors = [ mock(:record, tap_id: 123, broader_taps: [1234], title: "parent", attributes: {}),
                              mock(:record, tap_id: 1234, broader_taps: [12345], title: "mid", attributes: {}),
                              mock(:record, tap_id: 12345, broader_taps: [], title: "root", attributes: {})]

        record.stub(:authority_taps).with(:broader_term) { [123] }
        broader_ancestors.each do |record|
          enrichment.stub(:find_record).with(record.tap_id) { record }
          record.stub(:authority_taps).with(:broader_term) { record.broader_taps }
        end
        enrichment.stub(:find_record).with(nil) { nil }
      end

      it "should create a broad_related_authority for each broader_term above the direct parent" do
        enrichment.set_attribute_values
        enrichment.attributes[:authorities].should include({authority_id: 1234, name: "broad_related_authority", text: "mid"})
        enrichment.attributes[:authorities].should include({authority_id: 12345, name: "broad_related_authority", text: "root"})
      end
    end

    context "records ancestor has two broader_terms (not a real tree)" do
      before(:each) do
        broader_ancestors = [ mock(:record, tap_id: 3, broader_taps: [22, 21], title: "parent", attributes: {}),
                              mock(:record, tap_id: 21, broader_taps: [1], title: "mid_a", attributes: {}),
                              mock(:record, tap_id: 22, broader_taps: [1], title: "mid_b", attributes: {}),
                              mock(:record, tap_id: 1, broader_taps: [], title: "root", attributes: {})]

        record.stub(:authority_taps).with(:broader_term) { [3] }
        broader_ancestors.each do |record|
          enrichment.stub(:find_record).with(record.tap_id) { record }
          record.stub(:authority_taps).with(:broader_term) { record.broader_taps }
        end
        enrichment.stub(:find_record).with(nil) { nil }
      end

      it "should create a broad_related_authority for each broader_term above the direct parent" do
        enrichment.set_attribute_values
        enrichment.attributes[:authorities].should include({authority_id: 21, name: "broad_related_authority", text: "mid_a"})
        enrichment.attributes[:authorities].should include({authority_id: 22, name: "broad_related_authority", text: "mid_b"})
        enrichment.attributes[:authorities].should include({authority_id: 1, name: "broad_related_authority", text: "root"})
      end

      it "should not create duplicate authorities" do
        enrichment.set_attribute_values
        enrichment.attributes[:authorities].find_all{|a| a[:authority_id] == 1}.count.should eq 1
      end
    end

    context "record ancestors are cyclic" do
      before(:each) do
        broader_ancestors = [ mock(:record, tap_id: 1, broader_taps: [2], title: "parent", attributes: {}),
                              mock(:record, tap_id: 2, broader_taps: [1], title: "cyclic_root", attributes: {})]

        record.stub(:authority_taps).with(:broader_term) { [1] }
        broader_ancestors.each do |record|
          enrichment.stub(:find_record).with(record.tap_id) { record }
          record.stub(:authority_taps).with(:broader_term) { record.broader_taps }
        end
        enrichment.stub(:find_record).with(nil) { nil }
      end

      it "should create one broader_related_authority for each ancestor above parent" do
        enrichment.set_attribute_values
        enrichment.attributes[:authorities].should eq [{authority_id: 2, name: "broad_related_authority", text: "cyclic_root"}]
      end
    end
	end
end