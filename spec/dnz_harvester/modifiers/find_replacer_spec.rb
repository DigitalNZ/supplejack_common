require "spec_helper"

describe DnzHarvester::Modifiers::FindReplacer do

  let(:klass) { DnzHarvester::Modifiers::FindReplacer }
  let(:original_value) { ["http://google.com?width=100&height=200"] }
  let(:replacer) { klass.new(original_value, { /width=[\d]{1,4}/ => "width=520" }) }
  
  it "initializes the original value" do
    replacer.original_value.should eq original_value
  end

  it "initializes the replacement_rules" do
    replacer.replacement_rules.should eq({/width=[\d]{1,4}/ => "width=520"})
  end

  describe "modify" do
    it "modifies the value" do
      replacer.modify.should eq ["http://google.com?width=520&height=200"]
    end

    it "makes multiple modifications" do
      replacer.stub(:replacement_rules) { {/width=[\d]{1,4}/ => 'width=520', /height=[\d]{1,4}/ => 'height=310'} }
      replacer.modify.should eq ["http://google.com?width=520&height=310"]
    end

    it "returns only the values that matched" do
      replacer.stub(:replacement_rules) { {/depth=[\d]{1,4}/ => 'depth=800'} }
      replacer.modify.should eq []
    end
  end


end