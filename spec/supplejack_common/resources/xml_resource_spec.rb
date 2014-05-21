# The Supplejack Common code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack 

require "spec_helper"

describe SupplejackCommon::XmlResource do

  let(:klass) { SupplejackCommon::XmlResource }
  let(:resource) { klass.new("http://google.com/1", {namespaces: { dc: "http://purl.org/dc/elements/1.1/" } }) }

  describe "#initialize" do
    it "should set the namespaces class attribute" do
      resource.class._namespaces[:dc].should eq "http://purl.org/dc/elements/1.1/"
    end
  end
  
  describe "#document" do
    it "should parse the resource as XML" do
      resource.stub(:fetch_document) { "</xml>" }
      resource.document.should be_a Nokogiri::XML::Document
    end
  end

  describe "#strategy_value" do
    let(:doc) { double(:document) }

    it "should create a new XpathOption with the namespaces class attribute" do
      resource.stub(:document) { doc }
      SupplejackCommon::XpathOption.should_receive(:new).with(doc, {xpath: '/doc'}, dc: "http://purl.org/dc/elements/1.1/" ) { double(:option).as_null_object }
      resource.strategy_value({xpath: '/doc'})
    end
  end
end