

require "spec_helper"

describe SupplejackCommon::Modifiers::HtmlStripper do

  let(:klass) { SupplejackCommon::Modifiers::HtmlStripper }
  let(:stripper) { klass.new(" cats ") }

  describe "#initialize" do
    it "assigns the original_value" do
      stripper.original_value.should eq [" cats "]
    end
  end

  describe "#modify" do
    let(:html_string) { "<div id='top'>Stripped</div>" }

    it "strips html characters from a string" do
      stripper.stub(:original_value) { [html_string] }
      stripper.modify.should eq ["Stripped"]
    end

    it "doesn't try to strip_html from non strings" do
      node = mock(:node)
      stripper.stub(:original_value) { [node] }
      stripper.modify.should eq [node]
    end

    it 'removes invalid encoded characters' do
      invalid_html = 'Something with invalid characters \x80 and tags.'
      stripper.stub(:original_value) { [invalid_html] }
      stripper.modify.should eq ["Something with invalid characters \\x80 and tags."]
    end
  end
end