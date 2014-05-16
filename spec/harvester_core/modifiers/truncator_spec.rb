# The Supplejack code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack_core 

require "spec_helper"

describe HarvesterCore::Modifiers::Truncator do
  
  let(:klass) { HarvesterCore::Modifiers::Truncator }

  describe "#initialize" do
    it "assigns the original value and the length" do
      truncator = klass.new(["Value"], 300)
      truncator.original_value.should eq ["Value"]
      truncator.length.should eq 300
    end
  end

  describe "modify" do
    it "truncates the text to 30 charachters" do
      truncator = klass.new(["A string longer than 30 charachters"], 30, "")
      truncator.modify.should eq ["A string longer than 30 charac"]
    end

    it "adds a ommission at the end" do
      truncator = klass.new(["A string longer than 30 charachters"], 30, "...")
      truncator.modify.should eq ["A string longer than 30 cha..."]
    end
  end

end