require "spec_helper"

describe SupplejackCommon::AbstractEnrichment do
  let(:klass) { SupplejackCommon::AbstractEnrichment }
  let(:record) { mock(:record, id: 1234, attributes: {}) }
  let(:enrichment) { klass.new(:ndha_rights, {}, record, nil) }

  describe "#primary" do
    let(:fragment) { mock(:fragment).as_null_object }

    before do
      record.stub_chain(:fragments, :where).with(priority: 0) { [fragment] }
    end

    it "returns a wrapped fragment" do
      enrichment.primary.fragment.should eq fragment
    end

    it "should initialize a FragmentWrap object" do
      enrichment.primary.should be_a SupplejackCommon::FragmentWrap
    end
  end

  describe "#record_fragment" do
    let(:fragment) { mock(:fragment).as_null_object }

    before do
      record.stub_chain(:fragments, :where).with(source_id: :ndha) { [fragment] }
    end

    it "returns a wrapped fragment" do
      enrichment.record_fragment(:ndha).fragment.should eq fragment
    end

    it "should initialize a FragmentWrap object" do
      enrichment.record_fragment(:ndha).should be_a SupplejackCommon::FragmentWrap
    end
  end

  describe "#find_record" do
    it "should find record with tap id" do
      record.class.should_receive(:where).with("fragments.dc_identifier" => "tap:12345") { ["1", "2"] }
      enrichment.send(:find_record, "12345").should eq "1"
    end

    it "should return nil if the tap_id is nil" do
      enrichment.send(:find_record, nil).should eq nil
    end
  end

  context "priority is not specified" do
    it "has a priority of 1" do
      enrichment.attributes[:priority].should eq 1
    end
  end

  context "priority is specified as -1" do
    let(:enrichment) { klass.new(:ndha_rights, {priority: -1}, record, nil) }

    it "has a priority of -1" do
      enrichment.attributes[:priority].should eq -1
    end
  end

  it "sets the source_id to the specified name" do
    enrichment.attributes.should include(source_id: 'ndha_rights')
  end

  it "implements a before method that does nothing" do
    ->{klass.before(:method)}.should_not raise_error
  end

  it "implements a after method that does nothing" do
    ->{klass.after(:method)}.should_not raise_error
  end

end
