# The Supplejack code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack_core 

require "spec_helper"

describe HarvesterCore::Modifiers::Joiner do

  let(:klass) { HarvesterCore::Modifiers::Joiner }
  let(:join) { klass.new(["cats", "dogs"], ",") }

  describe "#initialize" do
    it "assigns the original_value and a separator" do
      join.original_value.should eq ["cats","dogs"]
      join.joiner.should eq ","
    end
  end

  describe "value" do
    it "joins the multiple elements into one" do
      join.modify.should eq ["cats,dogs"]
    end
  end
end