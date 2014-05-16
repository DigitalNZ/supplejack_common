# The Supplejack code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack_core 

require "spec_helper"

describe HarvesterCore::Modifiers::Splitter do
  
  let(:klass) { HarvesterCore::Modifiers::Splitter }

  describe "#initialize" do
    it "assigns the original value and the split_value" do
      splitter = klass.new(["Value"], /\s/)
      splitter.original_value.should eq ["Value"]
      splitter.split_value.should eq(/\s/)
    end
  end

  describe "modify" do
    it "splits the value based on a string" do
      splitter = klass.new(["A couple :: of values:: separated"], "::")
      splitter.modify.should eq ["A couple ", " of values", " separated"]
    end

    it "splits the value based on a regular expression" do
      splitter = klass.new(["Split on vowels"], /[aeiou]/)
      splitter.modify.should eq ["Spl", "t ", "n v", "w", "ls"]
    end
  end

end