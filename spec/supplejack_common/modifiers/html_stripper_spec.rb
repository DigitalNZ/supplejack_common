# frozen_string_literal: true

require 'spec_helper'

describe SupplejackCommon::Modifiers::HtmlStripper do
  subject { described_class.new(' cats ') }

  describe '#initialize' do
    it 'assigns the original_value' do
      expect(subject.original_value).to eq [' cats ']
    end
  end

  describe '#modify' do
    let(:html_string) { "<div id='top'>Stripped</div>" }

    it 'strips html characters from a string' do
      allow(subject).to receive(:original_value) { [html_string] }
      expect(subject.modify).to eq ['Stripped']
    end

    it "doesn't try to strip_html from non strings" do
      node = double(:node)
      allow(subject).to receive(:original_value) { [node] }
      expect(subject.modify).to eq [node]
    end

    it 'removes invalid encoded characters' do
      invalid_html = 'Something with invalid characters \x80 and tags.'
      allow(subject).to receive(:original_value) { [invalid_html] }
      expect(subject.modify).to eq ['Something with invalid characters \\x80 and tags.']
    end
  end
end
