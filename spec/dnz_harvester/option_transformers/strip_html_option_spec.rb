require "spec_helper"

describe DnzHarvester::OptionTransformers::StripHtmlOption do

  let(:klass) { DnzHarvester::OptionTransformers::StripHtmlOption }
  let(:stripper) { klass.new(" cats ") }

  describe "#initialize" do
    it "assigns the original_value" do
      stripper.original_value.should eq [" cats "]
    end
  end

  describe "#value" do
    let(:html_string) { "<div id='top'>Stripped</div>" }

    it "strips html characters from a string" do
      stripper.stub(:original_value) { [html_string] }
      stripper.value.should eq ["Stripped"]
    end

    it "doens't try to strip_html from non strings" do
      node = mock(:node)
      stripper.stub(:original_value) { [node] }
      stripper.value.should eq [node]
    end
  end
end