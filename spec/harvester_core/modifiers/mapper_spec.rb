# The Supplejack code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack_core 

require "spec_helper"

describe HarvesterCore::Modifiers::Mapper do

  let(:klass) { HarvesterCore::Modifiers::Mapper }
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

    it "returns the original value when it does not match any rule" do
      replacer.stub(:replacement_rules) { {/microsoft=[\d]/ => 'anything'} }
      replacer.modify.should eq original_value
    end
  end


end