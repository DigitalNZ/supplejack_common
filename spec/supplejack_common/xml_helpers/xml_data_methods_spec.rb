# frozen_string_literal: true

require 'spec_helper'

describe SupplejackCommon::XmlDataMethods do
  let(:klass) { SupplejackCommon::Xml::Base }
  let(:record) { klass.new('http://google.com') }

  describe 'full_raw_data' do
    before { allow(record).to receive(:raw_data) { '<record/>' } }

    context 'with namespaces' do
      before { klass._namespaces = { 'xmlns:foo' => 'bar' } }

      it 'should add the root node with namespaces' do
        expect(record.full_raw_data).to eq "<root xmlns:foo='bar'><record/></root>"
      end
    end

    context 'without namespaces' do
      before { klass._namespaces = nil }

      it 'should return the raw_data' do
        expect(record.full_raw_data).to eq '<record/>'
      end
    end
  end
end
