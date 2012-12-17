require "spec_helper"

describe DnzHarvester::PaginatedCollection do
  
  let(:klass) { DnzHarvester::PaginatedCollection }
  let(:collection) { klass.new(DnzHarvester::Base, {page_parameter: "page", type: "item", per_page_parameter: "per_page", per_page: 5, page: 1}, {limit: 1}) }

  
  describe "#initialize" do
    it "assigns the klass" do
      collection.klass.should eq DnzHarvester::Base
    end

    it "initializes pagination options" do
      collection.page_parameter.should eq "page"
      collection.per_page_parameter.should eq "per_page"
      collection.per_page.should eq 5
      collection.page.should eq 1
    end

    it "initializes a counter and extra options" do
      collection.counter.should eq 0
      collection.options.should eq(limit: 1)
    end
  end

  describe "#paginated?" do
    it "returns true when page and per_page are set" do
      collection.paginated?.should be_true
    end

    it "returns false when no pagination options are set" do
      collection = klass.new(DnzHarvester::Base, nil, {})
      collection.paginated?.should be_false
    end
  end

  describe "#next_url" do
    before { collection.klass.stub(:base_urls) { ["http://go.gle/"] } }

    context "not paginated" do
      before { collection.stub(:paginated?) { false } }

      it "returns the first base_url" do
        collection.next_url.should eq "http://go.gle/"
      end
    end

    context "paginated" do
      before do 
        collection.stub(:paginated?) { true }
        collection.stub(:url_options) { {page: 1, per_page: 10} }
      end

      it "returns the url with paginated options" do
        collection.next_url.should eq "http://go.gle/?page=1&per_page=10"
      end

      it "appends to existing url parameters" do
        collection.klass.stub(:base_urls) { ["http://go.gle/?sort=asc"] }
        collection.next_url.should eq "http://go.gle/?sort=asc&page=1&per_page=10"
      end
    end
  end

  describe "#url_options" do
    it "returns a hash with the url options" do
      collection.url_options.should eq({"page" => 1, "per_page" => 5})
    end
  end

  describe "#current_page" do
    context "page type pagination" do
      let(:collection) { klass.new(DnzHarvester::Base, {page_parameter: "page", type: "page", per_page_parameter: "per_page", per_page: 5, page: 1}) }

      it "returns the current_page" do
        collection.current_page.should eq 1
      end
    end

    context "item type pagination" do
      let(:collection) { klass.new(DnzHarvester::Base, {page_parameter: "page", type: "item", per_page_parameter: "per_page", per_page: 5, page: 1}) }

      it "returns the first page" do
        collection.current_page.should eq 1
      end

      it "returns the second page" do
        collection.stub(:page) { 6 }
        collection.current_page.should eq 2
      end

      it "returns the third page" do
        collection.stub(:page) { 11 }
        collection.current_page.should eq 3
      end
    end
  end

  describe "#total_pages" do
    it "returns the total number of pages" do
      collection.stub(:total) { 36 }
      collection.stub(:per_page) { 10 }
      collection.total_pages.should eq 4
    end
  end

  describe "increment_page_counter!" do
    context "page type pagination" do
      let(:collection) { klass.new(DnzHarvester::Base, {page_parameter: "page", type: "page", per_page_parameter: "per_page", per_page: 5, page: 1}) }

      it "increments the page by one" do
        collection.increment_page_counter!
        collection.page.should eq 2
      end
    end

    context "item type pagination" do
      let(:collection) { klass.new(DnzHarvester::Base, {page_parameter: "page", type: "item", per_page_parameter: "per_page", per_page: 5, page: 1}) }

      it "increments the page by the number per_page" do
        collection.increment_page_counter!
        collection.page.should eq 6
      end
    end
  end
end