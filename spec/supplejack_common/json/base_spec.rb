# The Supplejack Common code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# See https://github.com/DigitalNZ/supplejack for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs.
# http://digitalnz.org/supplejack

require "spec_helper"

describe SupplejackCommon::Json::Base do

  let(:klass) { SupplejackCommon::Json::Base }
  let(:document) { double(:document) }
  let(:record) { double(:record).as_null_object }

  after do
    klass._base_urls[klass.identifier] = []
    klass._attribute_definitions[klass.identifier] = {}
    klass._rejection_rules[klass.identifier] = nil
    klass._throttle = {}
    klass._request_timeout = 60000
  end

  describe ".record_selector" do
    it "stores the path to retrieve every record metadata" do
      klass.record_selector "$.items"
      klass._record_selector.should eq "$.items"
    end
  end

  describe ".records" do
    it "returns a paginated collection" do
      SupplejackCommon::PaginatedCollection.should_receive(:new).with(klass, {}, {})
      klass.records
    end
  end

  describe ".records_json" do
    let(:json_example_1) { %q{{"items": [{"title": "Record1"},{"title": "Record2"},{"title": "Record3"}]}} }
    let(:json_example_2) { %q{{"items": {"title": "Record1"}}} }

    it "returns an array of records with the parsed json" do
      klass.stub(:document) { json_example_1 }
      klass.record_selector "$.items"
      klass.records_json("http://goo.gle.com/1").should eq [{"title" => "Record1"}, {"title" => "Record2"}, {"title" => "Record3"}]
    end

    it "returns an array of records with the parsed json when json object is not array" do
      klass.stub(:document) { json_example_2 }
      klass.record_selector "$.items"
      klass.records_json("http://goo.gle.com/1").should eq [{"title" => "Record1"}]
    end
  end

  describe ".document" do
    let(:json) { %q{"description": "Some json!"} }

    context "json web document" do
      it "stores the raw json" do
        klass._throttle = {}
        SupplejackCommon::Request.should_receive(:get).with("http://google.com",60000, {}, {'Authorization': 'Token token="token"', 'x-api-key': 'gus'} ) { json }
        klass.document("http://google.com").should eq json
      end

      it 'stores json document at _document class attribute' do
        klass._throttle = {}
        SupplejackCommon::Request.should_receive(:get).with("http://google.com",60000, {}, {'Authorization': 'Token token="token"', 'x-api-key': 'gus'} ) { json }
        klass.document("http://google.com")
        expect(klass._document).to equal json
      end
    end

    context "json files" do
      it "stores the raw json" do
        File.should_receive(:read).with("file:///data/sites/data.json".gsub(/file:\/\//, "")) { json }
        klass.document("file:///data/sites/data.json").should eq json
      end
    end
  end

  describe ".fetch_records" do
    let(:document) { {"location" => 1234} }

    before do
      klass.stub(:records_json) { [{"title" => "Record1"}] }
      klass.stub(:document) { document }
    end

    it "initializes record for every json record" do
      klass.should_receive(:new).once.with({"title" => "Record1"}) { record }
      klass.fetch_records("http://google.com").should eq [record]
    end

    context "pagination options defined" do

      before do
        klass.stub(:pagination_options) { { total_selector: "totalResults" } }
      end

      it 'should set the total results if the json expression returns string' do
        JsonPath.should_receive(:on).with(document, "totalResults") { [22] }
        klass.fetch_records("http://google.com")
        klass._total_results.should eq 22
      end
    end
  end

  describe ".clear_definitions" do
    it "clears the _record_selector" do
      klass.record_selector "path"
      klass.clear_definitions
      klass._record_selector.should be_nil
    end

    it "clears the total results" do
      klass._total_results = 100
      klass.clear_definitions
      klass._total_results.should be_nil
    end
  end

  describe "#initialize" do
    it "initializes the record's attributes" do
      record = klass.new({"title" => "Dos"})
      record.json.should eq('{"title":"Dos"}')
    end

    it "returns an empty string when attributes are nil" do
      record = klass.new(nil)
      record.json.should eq('')
    end

    it "initializes from a json string" do
      data = {"title" => "Hi"}.to_json
      record = klass.new(data)
      record.document.should eq('{"title":"Hi"}')
    end
  end

  describe "#full_raw_data" do
    let(:record) { klass.new({"title" => "Hi"}) }

    it "should convert the raw_data to json" do
      record.full_raw_data.should eq({"title" => "Hi"}.to_json)
    end
  end

  describe "#strategy_value" do
    let(:record) { klass.new({"dc:creator" => "John", "dc:author" => "Fede"}) }

    it "returns the value of a attribute" do
      record.strategy_value(path: "$.'dc:creator'").should eq ["John"]
    end

    it "returns the values from multiple paths" do
      record.strategy_value(path: ["$.'dc:creator'", "$.'dc:author'"]).should eq ["John", "Fede"]
    end

    it "returns nil without :path" do
      record.strategy_value(path: nil).should be_nil
    end
  end

  describe "#fetch" do
    let(:record) { klass.new({"dc:creator" => "John", "dc:author" => "Fede"}) }
    let(:document) { {"location" => 1234} }

    before { record.stub(:document) { document } }

    it "returns the value object" do
      value = record.fetch("location")
      value.should be_a SupplejackCommon::AttributeValue
      value.to_a.should eq [1234]
    end
  end
end
