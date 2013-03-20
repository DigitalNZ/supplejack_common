require "spec_helper"

describe HarvesterCore::DSL do

  let(:klass) { HarvesterCore::Base }

  before(:each) do
    klass.clear_definitions
  end

  describe ".source_id" do
    it "sets the source_id for the current class" do
      klass.source_id "nlnzcat"
      klass._source_id[klass.identifier].should eq "nlnzcat"
    end
  end
  
  describe ".base_url" do
    it "adds the base_url" do
      klass.base_url "http://google.com"
      klass.base_urls.should include "http://google.com"
    end

    it "appends to a existing array of urls" do
      klass.base_url "http://google.com"
      klass.base_url "http://apple.com"
      klass.base_urls.should include "http://apple.com"
      klass.base_urls.size.should eq 2
    end
  end

  describe ".basic_auth" do
    it "should set the basic auth username and password" do
      klass.basic_auth "username", "password"
      klass._basic_auth[klass.identifier].should eq({username: "username", password: "password"})
    end
  end

  describe ".paginate" do
    let(:pagination) { mock(:pagination) }
    let(:options) { {page_parameter: "start-index", type: "item", per_page_parameter: "max-results", per_page: 50, page: 1} }

    it "initializes a pagination object" do
      klass.paginate options
      klass._pagination_options[klass.identifier].should eq options
    end
  end

  describe ".attribute" do
    it "adds a new attribute definition" do
      klass.attribute :category, option: true
      klass.attribute_definitions.should include(category: {option: true})
    end

    it "defaults to a empty set of options" do
      klass.attribute :category
      klass.attribute_definitions.should include(category: {})
    end

    it "stores the block" do
      klass.attribute :category do
        last(:description)
      end

      klass.attribute_definitions[:category][:block].should be_a Proc
    end
  end

  describe ".attributes" do
    it "adds multiple attribute definitions" do
      klass.attributes :category, :creator, option: true
      klass.attribute_definitions.should include(category: {option: true})
      klass.attribute_definitions.should include(creator: {option: true})
    end

    it "adds multiple attributes with a block" do
      klass.attributes :category, :creator do
        "Hi"
      end

      klass.attribute_definitions[:category][:block].should be_a(Proc)
      klass.attribute_definitions[:category][:block].should be_a(Proc)
    end
  end

  describe ".enrichment" do
    it "adds a enrichment definition" do
      klass.enrichment :ndha_rights do
        "Hi"
      end

      klass.enrichment_definitions[:ndha_rights].should be_a Proc
    end
  end

  describe ".with_options" do
    it "adds a attribute definition with the options" do
      class WithOptionsTest < HarvesterCore::Base
        with_options xpath: "name", if: {"span" => :label}, value: "div" do |w|
          w.attribute :title, label: "Name"
        end
      end

      WithOptionsTest.attribute_definitions.should include(title: {xpath: "name", if: {"span" => "Name"}, value: "div"})
    end
  end

  describe ".reject_if" do
    it "adds a new rejection rule" do
      klass.reject_if { "value" }
      klass._rejection_rules[klass.identifier].should be_a Proc
    end
  end

  describe ".throttle" do
    before do
      klass._throttle = nil
    end

    it "should store the throttling information" do
      klass.throttle :host => "gdata.youtube.com", :max_per_minute => 100
      klass._throttle.should eq [{:host => "gdata.youtube.com", :max_per_minute => 100}]
    end

    it "should store multiple throttle options" do
      klass.throttle :host => "www.google.com", :max_per_minute => 100
      klass.throttle :host => "www.yahoo.com", :max_per_minute => 100
      klass._throttle.should eq [{:host => "www.google.com", :max_per_minute => 100}, {:host => "www.yahoo.com", :max_per_minute => 100}]
    end
  end
end