# frozen_string_literal: true

require 'spec_helper'

describe SupplejackCommon::FileResource do
  subject { described_class.new('http://google.com/1', {}) }

  let(:file_contents) { File.read(File.dirname(__FILE__) + '/image.jpg') }

  before do
    allow(subject).to receive(:fetch_document) { file_contents }
  end

  describe '#document' do
    it 'initializes a file object' do
      expect(subject.document).to be_a Tempfile
    end
  end

  describe '#attributes' do
    %i[size height width mime_type extension url].each do |attribute|
      it "populates the #{attribute} field" do
        allow(subject).to receive(attribute).and_return('Hi')
        expect(subject.attributes).to include(attribute => 'Hi')
      end
    end
  end

  describe '#size' do
    it 'gets the size from the tempfile' do
      expect(subject.size).to eq 3094
    end
  end

  describe '#dimensions' do
    it 'returns the image dimensions' do
      expect(subject.dimensions).to eq [200, 100]
    end

    it 'only generates the dimensions once' do
      expect(Dimensions).to(receive(:dimensions).once.and_return([200, 100]))
      subject.dimensions
      subject.dimensions
    end
  end

  describe '#height' do
    it 'returns the height of the image' do
      expect(subject.height).to eq 100
    end
  end

  describe '#width' do
    it 'returns the width of the image' do
      expect(subject.width).to eq 200
    end
  end

  describe '#mime_type' do
    it 'returns a image type' do
      expect(subject.mime_type).to eq 'image'
    end
  end

  describe '#extension' do
    it 'returns the file extension by inspecting the path' do
      allow(subject).to receive(:url).and_return('http://google.com/image.jpg')
      expect(subject.extension).to eq 'jpg'
    end

    it 'downcases the extension' do
      allow(subject).to receive(:url).and_return('http://google.com/image.PNG')
      expect(subject.extension).to eq 'png'
    end

    it 'falls back on the mime type when the extension is not reliable' do
      allow(subject).to receive(:url).and_return('http://muse.aucklandmuseum.com/databases/images.aspx?FileName=F%3a%5cData%5cDBIMAGES%5cMAPS%5cf%5cG9230-1978.jpg&filepathtype=unc&width=240&height=600&cmd=scaledown')
      mime_content = allow(MimeMagic).to receive(:by_magic) { double(:mime, extensions: %w[jpe jpeg jpg]) }
      allow(MimeMagic).to receive(:by_path).and_return(nil)
      expect(subject.extension).to eq 'jpeg'
    end
  end

  describe '#fetch' do
    it 'returns the height, if requested' do
      expect(subject).to receive(:height).and_return(124)
      expect(subject.fetch(:height)).to eq 124
    end

    it 'returns the size, if requested' do
      expect(subject).to receive(:size).and_return(1243)
      expect(subject.fetch(:size)).to eq 1243
    end

    it 'returns the mime_type, if requested' do
      expect(subject).to receive(:mime_type).and_return('image/jpeg')
      expect(subject.fetch('mime_type')).to eq 'image/jpeg'
    end
  end

  describe '#strategy_value' do
    it 'calls fetch with the requested field from options' do
      expect(subject).to receive(:fetch).with(:width)
      subject.strategy_value(field: :width)
    end
  end
end
