# frozen_string_literal: true

require 'spec_helper'

describe SupplejackCommon::AbstractEnrichment do
  let(:fragment) { double(:fragment, priority: 0, source_id: :ndha) }
  let(:record) { double(:record, id: 1234, attributes: {}, fragments: [fragment]) }
  let(:enrichment) { described_class.new(:ndha_rights, {}, record, nil) }

  describe '#primary' do
    it 'returns a wrapped fragment' do
      expect(enrichment.primary.fragment).to eq fragment
    end

    it 'initializes a FragmentWrap object' do
      expect(enrichment.primary).to be_a SupplejackCommon::FragmentWrap
    end
  end

  describe '#record_fragment' do
    it 'returns a wrapped fragment' do
      expect(enrichment.record_fragment(:ndha).fragment).to eq fragment
    end

    it 'initializes a FragmentWrap object' do
      expect(enrichment.record_fragment(:ndha)).to be_a SupplejackCommon::FragmentWrap
    end
  end

  context 'priority is not specified' do
    it 'has a priority of 1' do
      expect(enrichment.attributes[:priority]).to eq 1
    end
  end

  context 'priority is specified as -1' do
    let(:enrichment) { described_class.new(:ndha_rights, { priority: -1 }, record, nil) }

    it 'has a priority of -1' do
      expect(enrichment.attributes[:priority]).to eq(-1)
    end
  end

  it 'sets the source_id to the specified name' do
    expect(enrichment.attributes).to include(source_id: 'ndha_rights')
  end

  it 'implements a before method that does nothing' do
    expect { described_class.before(:method) }.not_to raise_error
  end

  it 'implements a after method that does nothing' do
    expect { described_class.after(:method) }.not_to raise_error
  end
end
