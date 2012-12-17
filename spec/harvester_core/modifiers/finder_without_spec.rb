require "spec_helper"

describe HarvesterCore::Modifiers::FinderWithout do

  let(:klass) { HarvesterCore::Modifiers::FinderWithout }
  let(:original_value) { ["Images", "Videos", "Audio", "Data", "Dataset"] }
  let(:replacer) { klass.new(original_value, /data/i) }

  describe "modify" do
    context "fetch only 1" do
      before { replacer.stub(:scope) {:first} }

      it "returns the first result found" do
        replacer.modify.should eq ["Images"]
      end
    end

    context "fetch all" do
      before { replacer.stub(:scope) {:all} }

      it "returns the first result found" do
        replacer.modify.should eq ["Images", "Videos", "Audio"]
      end
    end
  end
end