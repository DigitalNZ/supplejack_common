require 'spec_helper'

describe DnzHarvester::Base do
  let(:klass) { DnzHarvester::Base }

  after(:each) do
    klass._base_urls[klass.identifier] = []
    klass._attribute_definitions[klass.identifier] = {}
  end

  describe "identifier" do
    before do
      class LibraryParser < DnzHarvester::Sitemap::Base; end
    end

    it "returns a unique identifier of the class" do
      LibraryParser.identifier.should eq "sitemap_library_parser"
    end

    it "memoizes the identifier" do
      LibraryParser.instance_variable_set("@identifier", nil)
      LibraryParser.should_receive(:ancestors).once { [nil, DnzHarvester::Sitemap::Base] }
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
  end

  describe "attributes" do
    it "adds multiple attribute definitions" do
      klass.attributes :category, :creator, option: true
      klass.attribute_definitions.should include(category: {option: true})
      klass.attribute_definitions.should include(creator: {option: true})
    end
  end

  describe ".with_options" do
    it "adds a attribute definition with the options" do
      class WithOptionsTest < DnzHarvester::Base
        with_options xpath: "name", if: {"span" => :label}, value: "div" do |w|
          w.attribute :title, label: "Name"
        end
      end

      WithOptionsTest.attribute_definitions.should include(title: {xpath: "name", if: {"span" => "Name"}, value: "div"})
    end
  end

  describe ".custom_instance_methods" do
    it "returns any method defined in the class" do
      class CustomMethodTest < DnzHarvester::Base
        def category; "Hi"; end
      end

      CustomMethodTest.custom_instance_methods.should include(:category)
    end
  end

  describe "#set_attribute_values" do
    let(:record) { klass.new }

    it "assigns the attribute values in a hash" do
      klass.attribute :category, {default: "Value"}
      record.stub(:attribute_value) { "Value" }
      record.set_attribute_values
      record.original_attributes.should include(category: "Value")
    end

    it "splits the values by the separator character" do
      klass.attribute :category, {default: "Value1, Value2", separator: ","}
      record.set_attribute_values
      record.original_attributes.should include(category: ["Value1", "Value2"])
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
      record.should_receive(:get_value_from).with(:some_path) { "Google" }
      record.attribute_value({from: :some_path}).should eq "Google"
    end

    it "gets the value from the conditional options" do
      DnzHarvester::ConditionalOption.should_receive(:new) { option_object }
      record.attribute_value({xpath: "table/tr", if: {"td[1]" => "dc.date"}, value: "td[2]"}, document).should eq "Google"
    end

    it "gets the value from the mapping option" do
      DnzHarvester::MappingOption.should_receive(:new) { option_object }
      record.attribute_value({xpath: "table/tr", mappings: {"Non commercial" => "CC-BY-NC", "Share" => "CC-BY-SA"}}, document).should eq "Google"
    end

    it "gets the value from the xpath option" do
      DnzHarvester::XpathOption.should_receive(:new) { option_object }
      record.attribute_value({xpath: "table/tr"}, document).should eq "Google"
    end
  end

  describe "#attributes" do
    let(:record) { klass.new }

    it "returns hash with attribute definitions" do
      record.stub(:attribute_names) { [:category] }
      record.stub(:category) { "Images" }
      record.attributes.should eq(category: "Images")
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