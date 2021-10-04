# frozen_string_literal: true

require 'spec_helper'

describe SupplejackCommon::Modifiers::HtmlStripper do
  subject { described_class.new(' cats ') }

  describe '#initialize' do
    it 'assigns the original_value' do
      subject.original_value.should eq [' cats ']
    end
  end

  describe '#modify' do
    let(:html_string) { "<div id='top'>Stripped</div>" }

    it 'strips html characters from a string' do
      subject.stub(:original_value) { [html_string] }
      subject.modify.should eq ['Stripped']
    end

    it "doesn't try to strip_html from non strings" do
      node = mock(:node)
      subject.stub(:original_value) { [node] }
      subject.modify.should eq [node]
    end

    it 'removes invalid encoded characters' do
      invalid_html = 'Something with invalid characters \x80 and tags.'
      subject.stub(:original_value) { [invalid_html] }
      subject.modify.should eq ['Something with invalid characters \\x80 and tags.']
    end
  end
end
