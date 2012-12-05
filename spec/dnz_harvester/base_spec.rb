require 'spec_helper'

describe DnzHarvester::Base do
  let(:klass) { DnzHarvester::Base }

  after(:each) do
    klass._base_urls = []
    klass._attribute_definitions = {}
  end

  describe ".base_url" do
    before { klass._base_urls = [] }

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
      klass.stub(:_base_urls) { ["http://google.com"] }
      klass.base_urls.should include "http://google.com"
    end
  end

  describe "#attribute_definitions" do
    it "returns the attributes defined" do
      klass.stub(:_attribute_definitions) { {category: {option: true}} }
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
    it "sets the default values" do
      klass._attribute_definitions = {content_partner: {default: "Google"}}
      klass.new.original_attributes.should include(content_partner: "Google")
    end

    it "sets the from value for a attribute" do
      class ValueParser < DnzHarvester::Base

        attribute :content_partner, from: :some_attribute_name

        def get_value_from(from_value)
          "Value"
        end
      end

      record = ValueParser.new
      record.set_attribute_values
      record.original_attributes.should include(content_partner: "Value")
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
      klass._attribute_definitions[:content_partner] = {default: "Google"}
      klass.new.attribute_names.should include(:content_partner)
    end

    it "returns any method defined in the class" do
      klass.stub(:custom_instance_methods) { [:category] }
      klass.new.attribute_names.should include(:category)
    end
  end
end