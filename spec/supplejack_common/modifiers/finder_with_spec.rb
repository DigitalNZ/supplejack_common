# The Supplejack Common code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack_core 

require "spec_helper"

describe SupplejackCommon::Modifiers::FinderWith do

  let(:klass) { SupplejackCommon::Modifiers::FinderWith }
  let(:original_value) { ["Images", "Videos", "Audio", "Data", "Dataset"] }
  let(:replacer) { klass.new(original_value, /data/i) }

  describe "modify" do
    context "fetch only 1" do
      before { replacer.stub(:scope) {:first} }

      it "returns the first result found" do
        replacer.modify.should eq ["Data"]
      end
    end

    context "fetch all" do
      before { replacer.stub(:scope) {:all} }

      it "returns the first result found" do
        replacer.modify.should eq ["Data", "Dataset"]
      end
    end
  end
end