require "spec_helper"

describe HarvesterCore::AttributeBuilder do

  let(:klass) { HarvesterCore::AttributeBuilder }
  let(:record) { mock(:record).as_null_object }
  
  describe "#attribute_value" do
    let(:option_object) { mock(:option, value: "Google") }

    it "returns the default value" do
      builder = klass.new(record, :category, {default: "Google"})
      builder.attribute_value.should eq "Google"
    end

    it "gets the value from another location" do
      builder = klass.new(record, :category, {xpath: "//category"})
      record.should_receive(:strategy_value).with({xpath: "//category"}) { "Google" }
      builder.attribute_value.should eq "Google"
    end
  end

  describe "#transform" do
    let(:builder) { klass.new(record, :category, {}) }

    it "splits the value" do
      builder = klass.new(record, :category, {separator: ", "})
      builder.stub(:attribute_value) { "Value1, Value2" }
      builder.transform.should eq ["Value1", "Value2"]
    end

    it "joins the values" do
      builder = klass.new(record, :category, {join: ", "})
      builder.stub(:attribute_value) { ["Value1", "Value2"] }
      builder.transform.should eq ["Value1, Value2"]
    end

    it "removes any trailing and leading characters" do
      builder.stub(:attribute_value) { " Hi " }
      builder.transform.should eq ["Hi"]
    end

    it "removes any html" do
      builder.stub(:attribute_value) { "<div id='top'>Stripped</div>" }
      builder.transform.should eq ["Stripped"]
    end

    it "truncates the value to 10 charachters" do
      builder = klass.new(record, :category, {truncate: 10})
      builder.stub(:attribute_value) { "Some random text longer that 10 charachters" }
      builder.transform.should eq ["Some ra..."]
    end

    it "parses a date" do
      builder = klass.new(record, :category, {date: true})
      builder.stub(:attribute_value) { "circa 1994" }
      builder.transform.should eq [Time.utc(1994,1,1,12)]
    end

    it "maps the value to another value" do
      builder = klass.new(record, :category, {mappings: {/lucky/ => 'unlucky'}})
      builder.stub(:attribute_value) { "Some lucky squirrel" }
      builder.transform.should eq ["Some unlucky squirrel"]
    end

    it "removes any duplicates" do
      builder.stub(:attribute_value) { ["Images", "Images", "Videos"] }
      builder.transform.should eq ["Images", "Videos"]
    end
  end

  describe "#value" do
    it "returns the value for the attribute" do
      builder = klass.new(record, :category, {default: "Video"})
      builder.value.should eq ["Video"]
    end

    it "rescues from errors in a block" do
      builder = klass.new(record, :category, {block: Proc.new { raise StandardError.new("Error!") } })
      builder.value.should be_nil
      builder.errors.should eq ["Error in the block: Error!"]
    end
  end
end