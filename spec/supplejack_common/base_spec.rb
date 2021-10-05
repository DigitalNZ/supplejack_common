# frozen_string_literal: true

require 'spec_helper'

class Snippet
end

describe SupplejackCommon::Base do
  before(:each) do
    described_class._base_urls[described_class.identifier] = []
    described_class._attribute_definitions[described_class.identifier] = {}
    described_class._basic_auth[described_class.identifier] = nil
    described_class._pagination_options[described_class.identifier] = nil
    described_class.environment = nil
  end

  describe 'identifier' do
    before { class LibraryParser < SupplejackCommon::Xml::Base; end }

    it 'returns a unique identifier of the class' do
      LibraryParser.identifier.should eq 'xml_library_parser'
    end

    it 'memoizes the identifier' do
      LibraryParser.instance_variable_set('@identifier', nil)
      LibraryParser.should_receive(:ancestors).once { [nil, SupplejackCommon::Xml::Base] }
      LibraryParser.identifier
      LibraryParser.identifier
    end
  end

  describe '.base_urls' do
    it 'returns the list of base_urls' do
      described_class.base_url 'http://google.com'
      described_class.base_urls.should include 'http://google.com'
    end

    it 'returns a list of urls with basic_auth' do
      described_class.base_url 'http://google.com'
      described_class.basic_auth 'username', 'password'
      described_class.base_urls.should include 'http://username:password@google.com'
    end

    it 'returns a list of urls within a specific environment' do
      described_class.environment = 'staging'
      described_class.base_url staging: 'http://google.com'
      described_class.base_urls.should include 'http://google.com'
    end

    it "returns nil when it doesn't match the environment" do
      described_class.environment = 'staging'
      described_class.base_url production: 'http://google.com'
      described_class.base_urls.should_not include 'http://google.com'
    end
  end

  describe '.environment_url' do
    it 'returns the url for the appropiate environment' do
      described_class.environment = 'staging'
      described_class.environment_url(staging: 'http://google.com').should eq 'http://google.com'
    end

    it 'returns the url no environment is specified' do
      described_class.environment_url('http://google.com').should eq 'http://google.com'
    end
  end

  describe '.basic_auth_credentials' do
    it 'returns the basic auth credentials' do
      described_class.basic_auth 'username', 'password'
      described_class.basic_auth_credentials.should eq(username: 'username', password: 'password')
    end
  end

  describe '.pagination' do
    it 'returns the pagination object' do
      described_class._pagination_options[described_class.identifier] = 'Hi'
      described_class.pagination_options.should eq 'Hi'
    end
  end

  describe '.clear_definitions' do
    it 'clears the base_urls' do
      described_class.base_url 'http://google.com'
      described_class.clear_definitions
      described_class.base_urls.should be_empty
    end

    it 'clears the attribute definitions' do
      described_class.attribute :subject, default: 'Base'
      described_class.clear_definitions
      described_class.attribute_definitions.should be_empty
    end

    it 'clears basic auth credentials' do
      described_class.basic_auth 'fede', 'secret'
      described_class.clear_definitions
      described_class.basic_auth_credentials.should be_nil
    end

    it 'clears pagination options' do
      described_class.paginate page_parameter: 'start', type: 'item', per_page_parameter: 'size'
      described_class.clear_definitions
      described_class.pagination_options.should be_nil
    end

    it 'clears the rejection rules' do
      described_class.reject_if { 'Hi' }
      described_class.clear_definitions
      described_class.rejection_rules.should be_nil
    end

    it 'clears the deletion rules' do
      described_class.delete_if { 'Hi' }
      described_class.clear_definitions
      described_class.deletion_rules.should be_nil
    end

    it 'clears the enrichment definitions' do
      described_class.enrichment :ndha_rights do
        'Hi'
      end

      described_class.clear_definitions
      described_class.enrichment_definitions.should be_empty
    end

    describe '.include_snippet' do
      before { Snippet.stub(:find_by_name) }

      it 'finds the snippet by name and environment' do
        described_class.stub_chain(:module_parent, :name) { 'OAI::Staging' }
        Snippet.should_receive(:find_by_name).with('snip', :staging)
        described_class.include_snippet('snip')
      end
    end
  end

  describe '#attribute_definitions' do
    it 'returns the attributes defined' do
      described_class.stub(:_attribute_definitions) { { described_class.identifier => { category: { option: true } } } }
      described_class.attribute_definitions.should eq(category: { option: true })
    end
  end

  describe '.rejection_rules' do
    it 'returns the rejection_rules for the described_class' do
      rules = [proc { 'Hi' }]
      described_class._rejection_rules[described_class.identifier] = rules
      described_class.rejection_rules.should eq rules
    end
  end

  describe '.deletion_rules' do
    it 'returns the deletion_rules for the described_class' do
      described_class._deletion_rules[described_class.identifier] = proc { 'Hi' }
      described_class.deletion_rules.should be_a Proc
    end
  end

  describe '.get_priority' do
    it 'returns the priority for the described_class' do
      described_class._priority[described_class.identifier] = 2
      described_class.get_priority.should eq 2
    end

    it 'returns 0 if no priority is set' do
      described_class._priority.delete(described_class.identifier)
      described_class.get_priority.should eq 0
    end
  end

  describe '.match_concepts_rule' do
    it 'returns the match_concepts_rule for the described_class' do
      described_class._match_concepts[described_class.identifier] = :create
      described_class.match_concepts_rule.should eq :create
    end
  end

  describe '#set_attribute_values' do
    let(:record) { described_class.new }

    it 'should set the priority' do
      described_class.priority 2
      record.set_attribute_values
      record.attributes.should include(priority: 2)
    end

    it 'should set the match_concepts' do
      described_class.match_concepts :create_or_match
      record.set_attribute_values
      record.attributes.should include(match_concepts: :create_or_match)
    end

    it 'should run values through the attribute value object so we do not get empty strings and nils' do
      described_class.attribute :category, default: ['value', nil]
      record.set_attribute_values
      record.attributes[:category].should eq ['value']
    end

    it 'assigns the attribute values in a hash' do
      described_class.attribute :category, default: 'Value'
      record.stub(:attribute_value) { 'Value' }
      record.set_attribute_values
      record.attributes.should include(category: ['Value'])
    end

    it 'splits the values by the separator character' do
      described_class.attribute :category, default: 'Value1, Value2', separator: ','
      record.set_attribute_values
      record.attributes.should include(category: %w[Value1 Value2])
    end

    it 'adds errors to field_errors' do
      described_class.attribute :date, default: '1999/1/1', date: true
      SupplejackCommon::AttributeBuilder.stub(:new).with(record, :date, default: '1999/1/1', date: true) { double(:builder, errors: ['Error']).as_null_object }
      record.set_attribute_values
      record.attributes.should include(date: nil)
      record.field_errors.should include(date: ['Error'])
    end

    it 'should rescue from exceptions and store it' do
      described_class.attribute :date
      SupplejackCommon::AttributeBuilder.stub(:new).and_raise(StandardError.new('Hi'))
      record.set_attribute_values
      record.request_error.should include(message: 'Hi')
    end
  end

  describe '#deletable?' do
    let(:record) { described_class.new }

    it 'is not deleteable if there are no deletion rules' do
      described_class.stub(:deletion_rules) { nil }
      record.deletable?.should be_false
    end

    it 'is deletable if the block evals to true' do
      described_class.delete_if { true }
      record.deletable?.should be_true
    end

    it 'is not deletable if the block evals to true' do
      described_class.delete_if { false }
      record.deletable?.should be_false
    end
  end

  describe '#rejected?' do
    let(:record) { described_class.new }

    it 'returns true if any rejection_rule is true' do
      described_class.stub(:rejection_rules) { [proc { false }, proc { true }] }
      record.rejected?.should be_true
    end

    it 'returns false if all rejection_rules are false' do
      described_class.stub(:rejection_rules) { [proc { false }, proc { false }] }
      record.rejected?.should be_false
    end

    it 'returns false if rejection_rules is undefined' do
      described_class.stub(:rejection_rules) { nil }
      record.rejected?.should be_false
    end
  end

  describe '#attribute_names' do
    it 'returns a list all attributes defined' do
      described_class.attribute :content_partner, default: 'Google'
      described_class.new.attribute_names.should include(:content_partner)
    end
  end
end
