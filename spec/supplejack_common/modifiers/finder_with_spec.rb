# frozen_string_literal: true

require 'spec_helper'

describe SupplejackCommon::Modifiers::FinderWith do
  let(:klass) { SupplejackCommon::Modifiers::FinderWith }
  let(:original_value) { %w[Images Videos Audio Data Dataset] }
  let(:replacer) { klass.new(original_value, /data/i) }

  describe 'modify' do
    context 'fetch only 1' do
      before { replacer.stub(:scope) { :first } }

      it 'returns the first result found' do
        replacer.modify.should eq ['Data']
      end
    end

    context 'fetch all' do
      before { replacer.stub(:scope) { :all } }

      it 'returns the first result found' do
        replacer.modify.should eq %w[Data Dataset]
      end
    end
  end
end
