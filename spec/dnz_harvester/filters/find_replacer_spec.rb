require "spec_helper"

describe DnzHarvester::Filters::FindReplacer do

  let(:klass) { DnzHarvester::Filters::FindReplacer }
  let(:record) { mock(:record, original_attributes: {url: "http://google.com?width=100&height=200"}) }
  let(:replacer) { klass.new(record, /width=[\d]{1,4}/, "width=520") }
  
  it "initializes the record" do
    replacer.record.should eq record
  end

  it "initializes the regexp as an array" do
    replacer.regexp.should eq [/width=[\d]{1,4}/]
  end

  it "initializes the substitute_value as an array" do
    replacer.substitute_value.should eq ['width=520']
  end

  describe "#within" do
    it "modifies the record url" do
      replacer.within(:url).should eq "http://google.com?width=520&height=200"
    end

    it "makes multiple modifications" do
      replacer.stub(:regexp) { [/width=[\d]{1,4}/, /height=[\d]{1,4}/] }
      replacer.stub(:substitute_value) { ["width=520", "height=310"] }
      replacer.within(:url).should eq "http://google.com?width=520&height=310"
    end

    it "ignores the substitute_value when there are more than the amount regular expressions" do
      replacer.stub(:substitute_value) { ["width=520", "height=310"] }
      replacer.within(:url).should eq "http://google.com?width=520&height=200"
    end

    it "ignores the substitute_value when there are less than the amount regular expressions" do
      replacer.stub(:substitute_value) { [] }
      replacer.within(:url).should eq []
    end

    it "returns only the values that matched" do
      replacer.stub(:regexp) { [/depth=[\d]{1,4}/] }
      replacer.within(:url).should eq []
    end
  end
end