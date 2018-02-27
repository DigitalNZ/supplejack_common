

require 'spec_helper'

describe SupplejackCommon::Oai::Base do

  let(:klass) { SupplejackCommon::Oai::Base }

  let(:header) { mock(:header, identifier: "123") }
  let(:root) { mock(:root).as_null_object }
  let(:oai_record) { mock(:oai_record, header: header, metadata: [root]).as_null_object }
  let(:record) { klass.new(oai_record) }

  before do
    klass._base_urls[klass.identifier] = []
    klass._attribute_definitions[klass.identifier] = {}
    klass.clear_definitions
  end

  describe ".client" do
    it "initializes a new OAI client" do
      klass.base_url "http://google.com"
      OAI::Client.should_receive(:new).with("http://google.com")
      klass.client
    end
  end

  describe "#metadata_prefix" do
    it "gets the metadata prefix" do
      klass.metadata_prefix 'prefix'
      klass.get_metadata_prefix.should eq 'prefix'
    end
  end

  describe "#set" do
    it "gets the set name" do
      klass.set 'name'
      klass.get_set.should eq 'name'
    end
  end

  describe ".records" do
    let(:client) { mock(:client) }
    let!(:paginator) { mock(:paginator) }

    before(:each) do
      klass.stub(:client) { client }
    end

    it "initializes a PaginatedCollection with the results" do
      SupplejackCommon::Oai::PaginatedCollection.should_receive(:new).with(client, {}, klass) { paginator }
      klass.records
    end

    it "accepts a :from option and pass it on to list_records" do
      date = Date.today
      SupplejackCommon::Oai::PaginatedCollection.should_receive(:new).with(client, {from: date}, klass) { paginator }
      klass.records(from: date)
    end

    it "accepts a :limit option" do
      SupplejackCommon::Oai::PaginatedCollection.should_receive(:new).with(client, {limit: 10}, klass) { paginator }
      klass.records(limit: 10)
    end

    it "add the :metadata_prefix option from the DSL" do
      SupplejackCommon::Oai::PaginatedCollection.should_receive(:new).with(client, {metadata_prefix: 'prefix'}, klass) { paginator }
      
      klass.metadata_prefix 'prefix'
      klass.records
    end

    it "add the :set option from the DSL" do
      SupplejackCommon::Oai::PaginatedCollection.should_receive(:new).with(client, {set: 'name'}, klass) { paginator }

      klass.set 'name'
      klass.records
    end

    it "does not pass on unknown options" do
      SupplejackCommon::Oai::PaginatedCollection.should_not_receive(:new).with(client, {golf_scores: :all}, klass) { paginator }
      klass.records(golf_scores: :all)
    end
  end

  describe "#resumption_token" do
    it "returns the current resumption_token" do
      klass.stub(:response) { mock(:response, resumption_token: "123456") }
      klass.resumption_token.should eq "123456"
    end

    it "returns nil when response is nil" do
      klass.stub(:response) { nil }
      klass.resumption_token.should be_nil
    end
  end

  describe "#initialize" do
    let(:xml) { "<record><title>Hi</title></record>" }

    it "initializes a record from XML" do
      record = klass.new(xml)
      record.original_xml.should eq xml
    end

    it "gets the XML from the OAI record" do
      element = mock(:element, to_s: xml)
      oai_record.stub(:element) { element }
      record = klass.new(oai_record)
      record.original_xml.should eq xml
    end
  end

  describe "#document" do
    let(:xml) { "<record><title>Hi</title></record>" }
    let(:record) { klass.new(xml) }
    let(:document) { mock(:document).as_null_object }

    it "should parse the xml with Nokogiri" do
      Nokogiri::XML.should_receive(:parse).with(xml) { document }
      record.document.should eq document
    end
  end

  describe "#raw_data" do
    let(:oai_record) { mock(:oai_record, :element => "<record><id>1</id></record>") }

    it "returns the raw xml" do
      record = klass.new(oai_record)
      record.raw_data.should eq "<?xml version=\"1.0\"?>\n<record>\n  <id>1</id>\n</record>\n"
    end
  end

  describe "#deletable?" do
    it "returns true when header has deleted attribute" do
      record.stub(:document) { Nokogiri.parse('<?xml version="1.0"?><record><header status="deleted"></header></record>') }
      record.deletable?.should be_true
    end    
    it "returns false when header does not have deleted attribute" do
      record.stub(:document) { Nokogiri.parse('<?xml version="1.0"?><record><header></header></record>') }
      record.deletable?.should be_false
    end
  end
end
