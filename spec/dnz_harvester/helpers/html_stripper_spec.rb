require "spec_helper"

describe DnzHarvester::HtmlStripper do

  let(:klass) { DnzHarvester::HtmlStripper }
  let(:stripper) { klass.new(" cats ") }

  describe "#initialize" do
    it "assigns the original_value" do
      stripper.original_value.should eq " cats "
    end
  end

  describe "#value" do
    let(:html_string) { "<div id='top'>Stripped</div>" }

    it "strips html characters from a string" do
      stripper.stub(:original_value) { html_string }
      stripper.value.should eq "Stripped"
    end

    it "strips html characters from a array" do
      stripper.stub(:original_value) { [html_string, html_string] }
      stripper.value.should eq ["Stripped", "Stripped"]
    end
  end
end