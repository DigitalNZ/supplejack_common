# frozen_string_literal: true

require 'spec_helper'

describe SupplejackCommon::Loader do
  let(:parser) do
    double(:parser, strategy: 'json', name: 'Europeana', content: 'class Europeana < SupplejackCommon::Json::Base; end',
                    file_name: 'europeana.rb')
  end
  let(:loader) { SupplejackCommon::Loader.new(parser, 'staging') }

  before(:each) do
    SupplejackCommon.parser_base_path = File.dirname(__FILE__) + '/tmp'
  end

  describe '#path' do
    it 'builds a absolute path to the temp file' do
      expect(loader.path).to eq "#{File.dirname(__FILE__)}/tmp/json/europeana.rb"
    end

    it 'memoizes the path' do
      expect(parser).to(receive(:file_name).once { '/path' })
      loader.path
      loader.path
    end
  end

  describe '#content_with_encoding' do
    it 'should add a utf-8 encoding to the top of the file' do
      expect(loader.content_with_encoding).to eq "# encoding: utf-8\r\nmodule LoadedParser::Staging\nclass Europeana < SupplejackCommon::Json::Base; end\nend"
    end
  end

  describe '#create_tempfile' do
    it 'creates a new tempfile with the path' do
      loader.create_tempfile
      expect(File.read(loader.path)).to eq "# encoding: utf-8\r\nmodule LoadedParser::Staging\nclass Europeana < SupplejackCommon::Json::Base; end\nend"
    end
  end

  describe '#parser_class_name' do
    it 'removes whitespace from the name' do
      allow(parser).to receive(:name) { 'NatLib Pages' }
      expect(loader.parser_class_name).to eq 'NatLibPages'
    end

    it 'capitalizes each word' do
      allow(parser).to receive(:name) { 'nlnzcat catalog' }
      expect(loader.parser_class_name).to eq 'NlnzcatCatalog'
    end
  end

  describe '#parser_class_name_with_module' do
    it 'removes whitespace from the name' do
      allow(parser).to receive(:name) { 'NatLib Pages' }
      expect(loader.parser_class_name_with_module).to eq 'LoadedParser::Staging::NatLibPages'
    end

    it 'capitalizes each word' do
      allow(parser).to receive(:name) { 'nlnzcat catalog' }
      expect(loader.parser_class_name_with_module).to eq 'LoadedParser::Staging::NlnzcatCatalog'
    end
  end

  describe '#parser_class' do
    before(:each) do
      loader.load_parser
    end

    it 'returns the class singleton' do
      expect(loader.parser_class).to eq LoadedParser::Staging::Europeana
    end
  end

  describe '#load_parser' do
    it 'creates the tempfile' do
      expect(loader).to receive(:create_tempfile)
      loader.load_parser
    end

    it 'clears the klass definitions' do
      expect(loader).to receive(:clear_parser_class_definitions)
      loader.load_parser
    end

    it 'loads the file' do
      expect(loader).to receive(:load).with(loader.path)
      expect(loader.load_parser).to be_truthy
    end
  end

  describe 'loaded?' do
    it 'loads the parser file' do
      expect(loader).to receive(:load_parser)
      loader.loaded?
    end

    it 'returns the @loaded value' do
      loader.instance_variable_set('@loaded', true)
      expect(loader.loaded?).to be_truthy
    end
  end

  describe 'clear_parser_class_definitions' do
    before(:each) do
      loader.load_parser
    end

    it 'clears the parser class definitions' do
      expect(LoadedParser::Staging::Europeana).to receive(:clear_definitions)
      loader.clear_parser_class_definitions
    end
  end
end
