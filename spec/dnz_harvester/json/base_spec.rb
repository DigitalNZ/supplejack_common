require "spec_helper"

describe DnzHarvester::Json::Base do
  
  let(:klass) { DnzHarvester::Json::Base }
  let(:document) { mock(:document) }
  let(:record) { mock(:record) }

  after do
    klass._base_urls[klass.identifier] = []
    klass._attribute_definitions[klass.identifier] = {}
  end

  describe ".record_selector" do
    it "stores the path to retrieve every record metadata" do
      klass.record_selector "&..items"
      klass._record_selector.should eq "&..items"
    end
  end

  describe ".records" do
    before { klass.stub(:records_json) { [{"title" => "Record1"}] } }

    it "initializes record for every json record" do
      klass.should_receive(:new).once.with({"title" => "Record1"}) { record }
      klass.records.should eq [record]
    end

    it "removes any record that it's reject_if block evaluates to false" do
      klass.reject_if { true }
      klass.records.should eq []
    end
  end

  describe ".records_json" do
    let(:json) { %q{{"items": [{"title": "Record1"},{"title": "Record2"},{"title": "Record3"}]}} }

    it "returns an array of records with the parsed json" do
      klass.stub(:document) { json }
      klass.record_selector "$..items"
      klass.records_json.should eq [{"title" => "Record1"}, {"title" => "Record2"}, {"title" => "Record3"}]
    end
  end

  describe ".document" do
    let(:json) { %q{"description": "Some json!"} }

    it "stores the raw json" do
      klass.base_url "http://google.com"
      DnzHarvester::Utils.should_receive(:get).with("http://google.com") { json }
      klass.document.should eq json
    end
  end

  describe "#initialize" do
    it "initializes the record's attributes" do
      record = klass.new({"title" => "Dos"})
      record.json_attributes.should eq({"title" => "Dos"})
    end

    it "returns an empty hash when attributes are nil" do
      record = klass.new(nil)
      record.json_attributes.should eq({})
    end
  end

  describe "#strategy_value" do
    let(:record) { klass.new({"dc:creator" => "John", "dc:author" => "Fede"}) }

    it "returns the value of a attribute" do
      record.strategy_value(path: "dc:creator").should eq "John"
    end

    it "returns the values from multiple paths" do
      record.strategy_value(path: ["dc:creator", "dc:author"]).should eq ["John", "Fede"]
    end

    it "returns nil without :path" do
      record.strategy_value(path: nil).should be_nil
    end
  end
end