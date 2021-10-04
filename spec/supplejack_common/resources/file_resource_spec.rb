# frozen_string_literal: true

require 'spec_helper'

describe SupplejackCommon::FileResource do
  subject { described_class.new('http://google.com/1', {}) }

  let(:file_contents) { File.read(File.dirname(__FILE__) + '/image.jpg') }

  before do
    subject.stub(:fetch_document) { file_contents }
  end

  describe '#document' do
    it 'should initialize a file object' do
      subject.document.should be_a Tempfile
    end
  end

  describe '#attributes' do
    %i[size height width mime_type extension url].each do |attribute|
      it "should populate the #{attribute} field" do
        subject.stub(attribute) { 'Hi' }
        subject.attributes.should include(attribute => 'Hi')
      end
    end
  end

  describe '#size' do
    it 'should get the size from the tempfile' do
      subject.size.should eq 3094
    end
  end

  describe '#dimensions' do
    it 'returns the image dimensions' do
      subject.dimensions.should eq [200, 100]
    end

    it 'only generates the dimensions once' do
      Dimensions.should_receive(:dimensions).once { [200, 100] }
      subject.dimensions
      subject.dimensions
    end
  end

  describe '#height' do
    it 'returns the height of the image' do
      subject.height.should eq 100
    end
  end

  describe '#width' do
    it 'returns the width of the image' do
      subject.width.should eq 200
    end
  end

  describe '#mime_type' do
    it 'returns a image type' do
      subject.mime_type.should eq 'image'
    end
  end

  describe '#extension' do
    it 'returns the file extension by inspecting the path' do
      subject.stub(:url) { 'http://google.com/image.jpg' }
      subject.extension.should eq 'jpg'
    end

    it 'downcases the extension' do
      subject.stub(:url) { 'http://google.com/image.PNG' }
      subject.extension.should eq 'png'
    end

    it 'falls back on the mime type when the extension is not reliable' do
      subject.stub(:url) { 'http://muse.aucklandmuseum.com/databases/images.aspx?FileName=F%3a%5cData%5cDBIMAGES%5cMAPS%5cf%5cG9230-1978.jpg&filepathtype=unc&width=240&height=600&cmd=scaledown' }
      mime_content = MimeMagic.stub(:by_magic) { mock(:mime, extensions: %w[jpe jpeg jpg]) }
      MimeMagic.stub(:by_path) { nil }
      subject.extension.should eq 'jpeg'
    end
  end

  describe '#fetch' do
    it 'returns the height, if requested' do
      subject.should_receive(:height) { 124 }
      subject.fetch(:height).should eq 124
    end

    it 'returns the size, if requested' do
      subject.should_receive(:size) { 1243 }
      subject.fetch(:size).should eq 1243
    end

    it 'returns the mime_type, if requested' do
      subject.should_receive(:mime_type) { 'image/jpeg' }
      subject.fetch('mime_type').should eq 'image/jpeg'
    end
  end

  describe '#strategy_value' do
    it 'calls fetch with the requested field from options' do
      subject.should_receive(:fetch).with(:width)
      subject.strategy_value(field: :width)
    end
  end
end
