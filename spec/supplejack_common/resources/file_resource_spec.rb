# The Supplejack Common code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack_core 

require "spec_helper"

describe SupplejackCommon::FileResource do
  
  let(:klass) { SupplejackCommon::FileResource }
  let(:resource) { klass.new("http://google.com/1", {}) }
  let(:file_contents) { File.read(File.dirname(__FILE__) + '/image.jpg') }

  before do
    resource.stub(:fetch_document) { file_contents }
  end

  describe "#document" do
    it "should initialize a file object" do
      resource.document.should be_a Tempfile
    end
  end

  describe "#attributes" do
    [:size, :height, :width, :mime_type, :extension, :url].each do |attribute|
      it "should populate the #{attribute} field" do
        resource.stub(attribute) { "Hi" }
        resource.attributes.should include(attribute => "Hi")
      end
    end
  end

  describe "#size" do
    it "should get the size from the tempfile" do
      resource.size.should eq 3094
    end
  end

  describe "#dimensions" do
    it "returns the image dimensions" do
      resource.dimensions.should eq [200,100]
    end

    it "only generates the dimensions once" do
      Dimensions.should_receive(:dimensions).once { [200,100] }
      resource.dimensions
      resource.dimensions
    end
  end

  describe "#height" do
    it "returns the height of the image" do
      resource.height.should eq 100
    end
  end

  describe "#width" do
    it "returns the width of the image" do
      resource.width.should eq 200
    end
  end

  describe "#mime_type" do
    it "returns a image type" do
      resource.mime_type.should eq "image"
    end
  end

  describe "#extension" do
    it "returns the file extension by inspecting the path" do
      resource.stub(:url) { "http://google.com/image.jpg" }
      resource.extension.should eq "jpg"
    end

    it "downcases the extension" do
      resource.stub(:url) { "http://google.com/image.PNG" }
      resource.extension.should eq "png"
    end

    it "falls back on the mime type when the extension is not reliable" do
      resource.stub(:url) { "http://muse.aucklandmuseum.com/databases/images.aspx?FileName=F%3a%5cData%5cDBIMAGES%5cMAPS%5cf%5cG9230-1978.jpg&filepathtype=unc&width=240&height=600&cmd=scaledown" }
      mime_content = MimeMagic.stub(:by_magic) { mock(:mime, extensions: ["jpe", "jpeg", "jpg"]) }
      MimeMagic.stub(:by_path) { nil }
      resource.extension.should eq "jpeg"
    end
  end

  describe "#fetch" do
    it "returns the height, if requested" do
      resource.should_receive(:height) {124}
      resource.fetch(:height).should eq 124
    end

    it "returns the size, if requested" do
      resource.should_receive(:size) {1243}
      resource.fetch(:size).should eq 1243
    end

    it "returns the mime_type, if requested" do
      resource.should_receive(:mime_type) {'image/jpeg'}
      resource.fetch('mime_type').should eq 'image/jpeg'
    end
  end

  describe "#strategy_value" do
    it "calls fetch with the requested field from options" do
      resource.should_receive(:fetch).with(:width)
      resource.strategy_value({field: :width})
    end
  end
end