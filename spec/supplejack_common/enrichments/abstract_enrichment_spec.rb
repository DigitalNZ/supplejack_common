# frozen_string_literal: true

require 'spec_helper'

describe SupplejackCommon::AbstractEnrichment do
  let(:klass) { SupplejackCommon::AbstractEnrichment }
  let(:fragment) { mock(:fragment, priority: 0, source_id: :ndha) }
  let(:record) { mock(:record, id: 1234, attributes: {}, fragments: [fragment]) }
  let(:enrichment) { klass.new(:ndha_rights, {}, record, nil) }

  describe '#primary' do
    it 'returns a wrapped fragment' do
      enrichment.primary.fragment.should eq fragment
    end

    it 'should initialize a FragmentWrap object' do
      enrichment.primary.should be_a SupplejackCommon::FragmentWrap
    end
  end

  describe '#record_fragment' do
    it 'returns a wrapped fragment' do
      enrichment.record_fragment(:ndha).fragment.should eq fragment
    end

    it 'should initialize a FragmentWrap object' do
      enrichment.record_fragment(:ndha).should be_a SupplejackCommon::FragmentWrap
    end
  end

  context 'priority is not specified' do
    it 'has a priority of 1' do
      enrichment.attributes[:priority].should eq 1
    end
  end

  context 'priority is specified as -1' do
    let(:enrichment) { klass.new(:ndha_rights, { priority: -1 }, record, nil) }

    it 'has a priority of -1' do
      enrichment.attributes[:priority].should eq -1
    end
  end

  it 'sets the source_id to the specified name' do
    enrichment.attributes.should include(source_id: 'ndha_rights')
  end

  it 'implements a before method that does nothing' do
    -> { klass.before(:method) }.should_not raise_error
  end

  it 'implements a after method that does nothing' do
    -> { klass.after(:method) }.should_not raise_error
  end
end
