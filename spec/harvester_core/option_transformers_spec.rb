require "spec_helper"

describe HarvesterCore::OptionTransformers do
  
  class OptionTransformersTest
    include HarvesterCore::OptionTransformers
  end

  let(:record) { OptionTransformersTest.new }

  describe "truncate_option" do
    it "truncates the value with a default omission" do
      record.truncate_option("More than 10 letters", 10).should eq ["More th..."]
    end

    it "truncates the value with a custom omission" do
      record.truncate_option("More than 10 letters", {length: 10, omission: ""}).should eq ["More than "]
    end
  end
end