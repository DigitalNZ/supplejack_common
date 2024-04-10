# frozen_string_literal: true

require 'spec_helper'

describe SupplejackCommon::Modifiers::FinderWith do
  let(:original_value) { %w[Images Videos Audio Data Dataset] }
  let(:replacer) { described_class.new(original_value, /data/i) }

  describe 'modify' do
    context 'fetch only 1' do
      before { allow(replacer).to receive(:scope) { :first } }

      it 'returns the first result found' do
        expect(replacer.modify).to eq ['Data']
      end
    end

    context 'fetch all' do
      before { allow(replacer).to receive(:scope) { :all } }

      it 'returns the first result found' do
        expect(replacer.modify).to eq %w[Data Dataset]
      end
    end
  end
end
