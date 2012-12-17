require "spec_helper"

describe HarvesterCore::OptionTransformers::MappingOption do
  
  let(:klass) { HarvesterCore::OptionTransformers::MappingOption }
  let(:mapping) { klass.new("Lucky squirrel", {/lucky/i => "Unlucky"}) }

  describe "#initialize" do
    it "assigns the original_value and the mappings" do
      mapping.original_value.should eq ["Lucky squirrel"]
      mapping.mappings.should eq({/lucky/i => "Unlucky"})
    end
  end

  describe "#value" do
    it "maps the value" do
      mapping.value.should eq ["Unlucky squirrel"]
    end

    it "returns the result from the first mapping that matches" do
      mapping.stub(:mappings) { {/fede/ => 'Something', /luck/i => 'unluck', /lu/ => 'mu'} }
      mapping.value.should eq ["unlucky squirrel"]
    end

    it "returns the original_value when it didn't match any mapping" do
      mapping.stub(:mappings) { {/fede/ => 'Something', /andy/i => 'unluck'} }
      mapping.value.should eq ["Lucky squirrel"]
    end
  end
end