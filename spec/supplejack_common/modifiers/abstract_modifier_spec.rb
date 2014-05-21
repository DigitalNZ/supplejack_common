# The Supplejack Common code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack 

require "spec_helper"

describe SupplejackCommon::Modifiers::AbstractModifier do
  
  let(:klass) { SupplejackCommon::Modifiers::AbstractModifier }
  let(:original_value) { ["Old Value"] }
  let(:modifier) { klass.new(original_value) }
  
  it "initializes the original value" do
    modifier.original_value.should eq original_value
  end

  describe "#value" do
    it "initializes a new AttributeValue object" do
      modifier.stub(:modify) { "New Value" }
      SupplejackCommon::AttributeValue.should_receive(:new).with("New Value") { mock(:attr_value) }
      modifier.value
    end
  end
end