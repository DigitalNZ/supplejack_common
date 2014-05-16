# The Supplejack code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack_core 

require "spec_helper"

describe HarvesterCore::Modifiers::WhitespaceCompactor do

  let(:klass) { HarvesterCore::Modifiers::WhitespaceCompactor }
  let(:whitespace) { klass.new(" cats ") }

  describe "#initialize" do
    it "assigns the original_value" do
      whitespace.original_value.should eq [" cats "]
    end
  end

  describe "#modify" do
    let(:node) { mock(:node) }

    it "returns a compacted array of values" do
      whitespace.stub(:original_value) { ["Dogs   Hotels  - foo", "Job   blah"] }
      whitespace.modify.should eq ["Dogs Hotels - foo", "Job blah"]
    end

    it "returns the same array when the elements are not string" do
      whitespace.stub(:original_value) { [ node, node ] }
      whitespace.modify.should eq [node, node]
    end
  end
end