# frozen_string_literal: true

require 'spec_helper'

describe SupplejackCommon::Modifiers::FinderWithout do
  let(:original_value) { %w[Images Videos Audio Data Dataset] }
  let(:replacer) { described_class.new(original_value, /data/i) }

  describe 'modify' do
    context 'fetch only 1' do
      before { allow(replacer).to receive(:scope).and_return(:first) }

      it 'returns the first result found' do
        expect(replacer.modify).to eq ['Images']
      end
    end

    context 'fetch all' do
      before { allow(replacer).to receive(:scope).and_return(:all) }

      it 'returns the first result found' do
        expect(replacer.modify).to eq %w[Images Videos Audio]
      end
    end
  end
end
