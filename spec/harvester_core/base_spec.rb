require 'spec_helper'

describe HarvesterCore::Base do
  let(:klass) { HarvesterCore::Base }

  before(:each) do
    klass._base_urls[klass.identifier] = []
    klass._attribute_definitions[klass.identifier] = {}
    klass._basic_auth[klass.identifier] = nil
    klass._pagination_options[klass.identifier] = nil
    klass.environment = nil
  end

  describe "identifier" do
    before do
      class LibraryParser < HarvesterCore::Xml::Base; end
    end

    it "returns a unique identifier of the class" do
      LibraryParser.identifier.should eq "xml_library_parser"
    end

    it "memoizes the identifier" do
      LibraryParser.instance_variable_set("@identifier", nil)
      LibraryParser.should_receive(:ancestors).once { [nil, HarvesterCore::Xml::Base] }
      LibraryParser.identifier
      LibraryParser.identifier
    end
  end

  describe ".base_url" do
    before { klass._base_urls[klass.identifier] = [] }

    it "adds the base_url" do
      klass.base_url "http://google.com"
      klass.base_urls.should include "http://google.com"
    end

    it "appends to a existing array of urls" do
      klass.base_url "http://google.com"
      klass.base_url "http://apple.com"
      klass.base_urls.should include "http://apple.com"
      klass.base_urls.size.should eq 2
    end
  end

  describe ".base_urls" do
    it "returns the list of base_urls" do
      klass.base_url "http://google.com"
      klass.base_urls.should include "http://google.com"
    end

    it "returns a list of urls with basic_auth" do
      klass.base_url "http://google.com"
      klass.basic_auth "username", "password"
      klass.base_urls.should include "http://username:password@google.com"
    end

    it "returns a list of urls within a specific environment" do
      klass.environment = "staging"
      klass.base_url staging: "http://google.com"
      klass.base_urls.should include "http://google.com"
    end

    it "returns nil when it doesn't match the environment" do
      klass.environment = "staging"
      klass.base_url production: "http://google.com"
      klass.base_urls.should_not include "http://google.com"
    end
  end

  describe ".environment_url" do
    it "returns the url for the appropiate environment" do
      klass.environment = "staging"
      klass.environment_url({staging: "http://google.com"}).should eq "http://google.com"
    end

    it "returns the url no environment is specified" do
      klass.environment_url("http://google.com").should eq "http://google.com"
    end
  end

  describe ".basic_auth" do
    it "should set the basic auth username and password" do
      klass.basic_auth "username", "password"
      klass._basic_auth[klass.identifier].should eq({username: "username", password: "password"})
    end
  end

  describe ".basic_auth_credentials" do
    it "returns the basic auth credentials" do
      klass.basic_auth "username", "password"
      klass.basic_auth_credentials.should eq({username: "username", password: "password"})
    end
  end

  describe ".paginate" do
    let(:pagination) { mock(:pagination) }
    let(:options) { {page_parameter: "start-index", type: "item", per_page_parameter: "max-results", per_page: 50, page: 1} }

    it "initializes a pagination object" do
      klass.paginate options
      klass._pagination_options[klass.identifier].should eq options
    end
  end

  describe ".pagination" do
    it "returns the pagination object" do
      klass._pagination_options[klass.identifier] = "Hi"
      klass.pagination_options.should eq "Hi"
    end
  end

  describe ".clear_definitions" do
    it "clears the base_urls" do
      klass.base_url "http://google.com"
      klass.clear_definitions
      klass.base_urls.should be_empty
    end

    it "clears the attribute definitions" do
      klass.attribute :subject, default: "Base"
      klass.clear_definitions
      klass.attribute_definitions.should be_empty
    end

    it "clears basic auth credentials" do
      klass.basic_auth "fede", "secret"
      klass.clear_definitions
      klass.basic_auth_credentials.should be_nil
    end

    it "clears pagination options" do
      klass.paginate page_parameter: "start", type: "item", per_page_parameter: "size"
      klass.clear_definitions
      klass.pagination_options.should be_nil
    end

    it "clears the rejection rules" do
      klass.reject_if { puts "Hi" }
      klass.clear_definitions
      klass.rejection_rules.should be_nil
    end
    
  end

  describe "#attribute_definitions" do
    it "returns the attributes defined" do
      klass.stub(:_attribute_definitions) { {klass.identifier => {category: {option: true}}} }
      klass.attribute_definitions.should eq(category: {option: true})
    end
  end

  describe ".attribute" do
    it "adds a new attribute definition" do
      klass.attribute :category, option: true
      klass.attribute_definitions.should include(category: {option: true})
    end

    it "defaults to a empty set of options" do
      klass.attribute :category
      klass.attribute_definitions.should include(category: {})
    end

    it "stores the block" do
      klass.attribute :category do
        last(:description)
      end

      klass.attribute_definitions[:category][:block].should be_a Proc
    end
  end

  describe ".attributes" do
    it "adds multiple attribute definitions" do
      klass.attributes :category, :creator, option: true
      klass.attribute_definitions.should include(category: {option: true})
      klass.attribute_definitions.should include(creator: {option: true})
    end

    it "adds multiple attributes with a block" do
      klass.attributes :category, :creator do
        puts "Hi"
      end

      klass.attribute_definitions[:category][:block].should be_a(Proc)
      klass.attribute_definitions[:category][:block].should be_a(Proc)
    end
  end

  describe ".with_options" do
    it "adds a attribute definition with the options" do
      class WithOptionsTest < HarvesterCore::Base
        with_options xpath: "name", if: {"span" => :label}, value: "div" do |w|
          w.attribute :title, label: "Name"
        end
      end

      WithOptionsTest.attribute_definitions.should include(title: {xpath: "name", if: {"span" => "Name"}, value: "div"})
    end
  end

  describe ".custom_instance_methods" do
    it "returns any method defined in the class" do
      class CustomMethodTest < HarvesterCore::Base
        def category; "Hi"; end
      end

      CustomMethodTest.custom_instance_methods.should include(:category)
    end
  end

  describe ".reject_if" do
    it "adds a new rejection rule" do
      klass.reject_if { "value" }
      klass._rejection_rules[klass.identifier].should be_a Proc
    end
  end

  describe ".rejection_rules" do
    it "returns the rejection_rules for the klass" do
      klass._rejection_rules[klass.identifier] = Proc.new { "Hi" }
      klass.rejection_rules.should be_a Proc
    end
  end

  describe ".throttle" do
    before do
      klass._throttle = nil
    end

    it "should store the throttling information" do
      klass.throttle :host => "gdata.youtube.com", :max_per_minute => 100
      klass._throttle.should eq [{:host => "gdata.youtube.com", :max_per_minute => 100}]
    end

    it "should store multiple throttle options" do
      klass.throttle :host => "www.google.com", :max_per_minute => 100
      klass.throttle :host => "www.yahoo.com", :max_per_minute => 100
      klass._throttle.should eq [{:host => "www.google.com", :max_per_minute => 100}, {:host => "www.yahoo.com", :max_per_minute => 100}]
    end
  end

  describe "#set_attribute_values" do
    let(:record) { klass.new }

    it "assigns the attribute values in a hash" do
      klass.attribute :category, {default: "Value"}
      record.stub(:attribute_value) { "Value" }
      record.set_attribute_values
      record.original_attributes.should include(category: ["Value"])
    end

    it "splits the values by the separator character" do
      klass.attribute :category, {default: "Value1, Value2", separator: ","}
      record.set_attribute_values
      record.original_attributes.should include(category: ["Value1", "Value2"])
    end

    it "rescues from a transformation error" do
      klass.attribute :date, default: "1999/1/1", date: true
      record.stub(:transformed_attribute_value).and_raise(HarvesterCore::TransformationError.new("Error"))
      record.set_attribute_values
      record.original_attributes.should include(date: nil)
      record.field_errors.should include(date: ["Error"])
    end
  end

  describe "#attribute_value" do
    let(:record) { klass.new }
    let(:document) { mock(:document) }
    let(:option_object) { mock(:option, value: "Google") }

    it "returns the default value" do
      record.attribute_value({default: "Google"}).should eq "Google"
    end

    it "gets the value from another location" do
      record.should_receive(:strategy_value).with(from: :some_path) { "Google" }
      record.attribute_value({from: :some_path}).should eq "Google"
    end

    it "gets the value from the conditional options" do
      HarvesterCore::ConditionalOption.should_receive(:new) { option_object }
      record.attribute_value({xpath: "table/tr", if: {"td[1]" => "dc.date"}, value: "td[2]"}, document).should eq "Google"
    end

    it "gets the value from the xpath option" do
      HarvesterCore::XpathOption.should_receive(:new) { option_object }
      record.attribute_value({xpath: "table/tr"}, document).should eq "Google"
    end
  end

  describe "#transformed_attribute_value" do
    let(:record) { klass.new }

    it "splits the value" do
      record.stub(:attribute_value) { "Value1, Value2" }
      record.transformed_attribute_value({separator: ","}).should eq ["Value1", "Value2"]
    end

    it "joins the values" do
      record.stub(:attribute_value) { ["Value1", "Value2"] }
      record.transformed_attribute_value({join: ", "}).should eq ["Value1, Value2"]
    end

    it "removes any trailing and leading characters" do
      record.stub(:attribute_value) { " Hi " }
      record.transformed_attribute_value({}).should eq ["Hi"]
    end

    it "removes any html" do
      record.stub(:attribute_value) { "<div id='top'>Stripped</div>" }
      record.transformed_attribute_value({}).should eq ["Stripped"]
    end

    it "truncates the value to 10 charachters" do
      record.stub(:attribute_value) { "Some random text longer that 10 charachters" }
      record.transformed_attribute_value({truncate: 10}).should eq ["Some rando"]
    end

    it "parses a date" do
      record.stub(:attribute_value) { "circa 1994" }
      record.transformed_attribute_value({date: true}).should eq [Time.utc(1994,1,1,12)]
    end

    it "maps the value to another value" do
      record.stub(:attribute_value) { "Some lucky squirrel" }
      record.transformed_attribute_value({mappings: {/lucky/ => 'unlucky'}}).should eq ["Some unlucky squirrel"]
    end

    it "removes any duplicates" do
      record.stub(:attribute_value) { ["Images", "Images", "Videos"] }
      record.transformed_attribute_value({}).should eq ["Images", "Videos"]
    end
  end

  describe "#attributes" do
    let(:record) { klass.new }

    it "returns hash with attribute definitions" do
      record.stub(:attribute_names) { [:category] }
      record.stub(:final_attribute_value).with(:category) { "Images" }
      record.attributes.should eq(category: "Images")
    end
  end

  describe "#final_attribute_value" do
    let(:record) { klass.new }

    it "executes the method with the name" do
      klass._attribute_definitions[klass.identifier][:category] = {default: "Video"}
      record.set_attribute_values
      record.final_attribute_value(:category).should eq ["Video"]
    end

    it "rescues from field_errors in a block" do
      record.stub(:strategy_value) { nil }
      klass._attribute_definitions[klass.identifier][:category] = {block: Proc.new { raise StandardError.new("Error!") } }
      record.final_attribute_value(:category).should be_nil
      record.field_errors.should include(category: ["Error in the block: Error!"])
    end
  end

  describe "#attribute_names" do
    it "returns a list all attributes defined" do
      klass.attribute :content_partner, {default: "Google"}
      klass.new.attribute_names.should include(:content_partner)
    end

    it "returns any method defined in the class" do
      klass.stub(:custom_instance_methods) { [:category] }
      klass.new.attribute_names.should include(:category)
    end
  end
end