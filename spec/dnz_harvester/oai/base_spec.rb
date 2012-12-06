require 'spec_helper'

describe DnzHarvester::Oai::Base do

  let(:klass) { DnzHarvester::Oai::Base }

  let(:header) { mock(:header, identifier: "123") }
  let(:root) { mock(:root).as_null_object }
  let(:oai_record) { mock(:oai_record, header: header, metadata: [root]).as_null_object }
  let(:record) { klass.new(oai_record) }

  describe ".enrich" do
    it "adds a enrichment definition" do
      class OaiEnrich < DnzHarvester::Oai::Base
        enrich :citation, xpath: "table/td"
      end

      OaiEnrich._enrichment_definitions.should include(citation: {xpath: "table/td"})
    end
  end

  describe ".client" do
    it "initializes a new OAI client" do
      klass.base_url "http://google.com"
      OAI::Client.should_receive(:new).with("http://google.com")
      klass.client
    end
  end

  describe ".records" do
    let(:record) { mock(:record) }
    let(:client) { mock(:client, list_records: [record]) }

    it "initializes a new Oai record for every result" do
      klass.stub(:client) { client }
      klass.should_receive(:new).once.with(record)
      klass.records
    end
  end

  describe "#set_attribute_values" do
    it "sets the header identifier" do
      record.set_attribute_values
      record.original_attributes.should include(identifier: "123")
    end

    it "sets the default values" do
      klass.attribute :category, {default: "Papers"}
      record.set_attribute_values
      record.original_attributes.should include(category: "Papers")
    end

    it "extracts the values from the root" do
      klass.attribute :title, {from: "dc:title"}
      record.should_receive(:get_value_from).with("dc:title") { "Dogs" }
      record.set_attribute_values
      record.original_attributes.should include(title: "Dogs")
    end
  end

  describe "#attributes" do
    it "should enrich the record" do
      record.stub(:attribute_names) { [] }
      record.should_receive(:enrich_record)
      record.attributes
    end
  end

  describe "#attribute_names" do
    it "should add the enrichment definitions" do
      class OaiEnrich < DnzHarvester::Oai::Base
        enrich :citation, xpath: "table/td"
      end

      OaiEnrich.new(oai_record).attribute_names.should include(:citation)
    end
  end

  describe "#get_value_from" do
    let(:root) { mock(:rexml_element).as_null_object }
    let(:node) { mock(:node, texts: "Dogs and cats") }

    before do
      record.stub(:root) { root }
    end

    it "extracts a value for a given node name" do
      root.should_receive(:get_elements).with("dc:title") { [node] }
      record.get_value_from("dc:title").should eq ["Dogs and cats"]
    end
  end

  describe "#enrich_record" do
    let(:enrichment_doc) { mock(:document) }
    let(:options) { {xpath: "table/tr", if: {"td[1]" => "dc.identifier.citation"}, value: "td[2]"} }
    before { record.stub(:enrichment_document) { enrichment_doc } }

    context "without a enrichment url" do
      it "returns nil" do
        record.stub(:enrichment_url) { "" }
        record.enrich_record.should be_nil
      end
    end

    context "with a enrichment_url" do
      before do
        klass._enrichment_definitions = {citation: options}
        record.stub(:enrichment_url) { "http://google.com" }
      end

      it "populates with the enrichment values" do
        conditional_option = mock(:conditional_option, value: "Dogs")
        DnzHarvester::ConditionalOption.should_receive(:new).with(enrichment_doc, options) { conditional_option }
        record.enrich_record
        record.original_attributes.should include(citation: "Dogs")
      end

      it "should not populate the value when blank" do
        conditional_option = mock(:conditional_option, value: "")
        DnzHarvester::ConditionalOption.should_receive(:new).with(enrichment_doc, options) { conditional_option }
        record.enrich_record
        record.original_attributes.should_not have_key(:citation)
      end
    end
  end
end