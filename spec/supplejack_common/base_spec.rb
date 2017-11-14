# The Supplejack Common code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# See https://github.com/DigitalNZ/supplejack for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs.
# http://digitalnz.org/supplejack

require 'spec_helper'

class Snippet

end

describe SupplejackCommon::Base do
  let(:klass) { SupplejackCommon::Base }

  before(:each) do
    klass._base_urls[klass.identifier] = []
    klass._attribute_definitions[klass.identifier] = {}
    klass._basic_auth[klass.identifier] = nil
    klass._pagination_options[klass.identifier] = nil
    klass.environment = nil
  end

  describe "identifier" do
    before do
      class LibraryParser < SupplejackCommon::Xml::Base; end
    end

    it "returns a unique identifier of the class" do
      LibraryParser.identifier.should eq "xml_library_parser"
    end

    it "memoizes the identifier" do
      LibraryParser.instance_variable_set("@identifier", nil)
      LibraryParser.should_receive(:ancestors).once { [nil, SupplejackCommon::Xml::Base] }
      LibraryParser.identifier
      LibraryParser.identifier
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

  describe ".basic_auth_credentials" do
    it "returns the basic auth credentials" do
      klass.basic_auth "username", "password"
      klass.basic_auth_credentials.should eq({username: "username", password: "password"})
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
      klass.reject_if { "Hi" }
      klass.clear_definitions
      klass.rejection_rules.should be_nil
    end

    it "clears the deletion rules" do
      klass.delete_if { "Hi" }
      klass.clear_definitions
      klass.deletion_rules.should be_nil
    end

    it "clears the enrichment definitions" do
      klass.enrichment :ndha_rights do
        "Hi"
      end
      klass.clear_definitions
      klass.enrichment_definitions.should be_empty
    end

    describe ".include_snippet" do
      before do
        Snippet.stub(:find_by_name)
      end

      it "finds the snippet by name and environment" do
        klass.stub_chain(:parent, :name) { "OAI::Staging" }
        Snippet.should_receive(:find_by_name).with("snip", :staging)
        klass.include_snippet("snip")
      end
    end

  end

  describe "#attribute_definitions" do
    it "returns the attributes defined" do
      klass.stub(:_attribute_definitions) { {klass.identifier => {category: {option: true}}} }
      klass.attribute_definitions.should eq(category: {option: true})
    end
  end

  describe ".rejection_rules" do
    it "returns the rejection_rules for the klass" do
      rules = [Proc.new { "Hi" }]
      klass._rejection_rules[klass.identifier] = rules
      klass.rejection_rules.should eq rules
    end
  end

  describe ".deletion_rules" do
    it "returns the deletion_rules for the klass" do
      klass._deletion_rules[klass.identifier] = Proc.new { "Hi" }
      klass.deletion_rules.should be_a Proc
    end
  end

  describe ".get_priority" do
    it "returns the priority for the klass" do
      klass._priority[klass.identifier] = 2
      klass.get_priority.should eq 2
    end

    it "returns 0 if no priority is set" do
      klass._priority.delete(klass.identifier)
      klass.get_priority.should eq 0
    end
  end

  describe ".match_concepts_rule" do
    it "returns the match_concepts_rule for the klass" do
      klass._match_concepts[klass.identifier] = :create
      klass.match_concepts_rule.should eq :create
    end
  end

  describe "#set_attribute_values" do
    let(:record) { klass.new }

    it "should set the priority" do
      klass.priority 2
      record.set_attribute_values
      record.attributes.should include(priority: 2)
    end

    it "should set the match_concepts" do
      klass.match_concepts :create_or_match
      record.set_attribute_values
      record.attributes.should include(match_concepts: :create_or_match)
    end

    it "should run values through the attribute value object so we do not get empty strings and nils" do
      klass.attribute :category, {default: ["value", nil]}
      record.set_attribute_values
      record.attributes[:category].should eq ["value"]
    end

    it "assigns the attribute values in a hash" do
      klass.attribute :category, {default: "Value"}
      record.stub(:attribute_value) { "Value" }
      record.set_attribute_values
      record.attributes.should include(category: ["Value"])
    end

    it "splits the values by the separator character" do
      klass.attribute :category, {default: "Value1, Value2", separator: ","}
      record.set_attribute_values
      record.attributes.should include(category: ["Value1", "Value2"])
    end

    it "adds errors to field_errors" do
      klass.attribute :date, default: "1999/1/1", date: true
      SupplejackCommon::AttributeBuilder.stub(:new).with(record, :date, {default: "1999/1/1", date: true}) { double(:builder, errors: ["Error"]).as_null_object }
      record.set_attribute_values
      record.attributes.should include(date: nil)
      record.field_errors.should include(date: ["Error"])
    end

    it "should rescue from exceptions and store it" do
      klass.attribute :date
      SupplejackCommon::AttributeBuilder.stub(:new).and_raise(StandardError.new("Hi"))
      record.set_attribute_values
      record.request_error.should include({message: "Hi"})
    end
  end

  describe "#deletable?" do
    let(:record) { klass.new }

    it "is not deleteable if there are no deletion rules" do
      klass.stub(:deletion_rules) { nil }
      record.deletable?.should be_false
    end

    it "is deletable if the block evals to true" do
      klass.delete_if { true }
      record.deletable?.should be_true
    end

    it "is not deletable if the block evals to true" do
      klass.delete_if { false }
      record.deletable?.should be_false
    end
  end

  describe "#rejected?" do
    let(:record) { klass.new }

    it "returns true if any rejection_rule is true" do
      klass.stub(:rejection_rules) { [Proc.new { false }, Proc.new { true } ] }
      record.rejected?.should be_true
    end

    it "returns false if all rejection_rules are false" do
      klass.stub(:rejection_rules) { [Proc.new { false }, Proc.new { false } ] }
      record.rejected?.should be_false
    end

    it "returns false if rejection_rules is undefined" do
      klass.stub(:rejection_rules) { nil }
      record.rejected?.should be_false
    end
  end

  describe "#attribute_names" do
    it "returns a list all attributes defined" do
      klass.attribute :content_partner, {default: "Google"}
      klass.new.attribute_names.should include(:content_partner)
    end
  end
end
