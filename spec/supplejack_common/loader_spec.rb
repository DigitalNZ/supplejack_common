# frozen_string_literal: true

require 'spec_helper'

describe SupplejackCommon::Loader do
  let(:parser) { mock(:parser, strategy: 'json', name: 'Europeana', content: 'class Europeana < SupplejackCommon::Json::Base; end', file_name: 'europeana.rb') }
  let(:loader) { SupplejackCommon::Loader.new(parser, 'staging') }

  before(:each) do
    SupplejackCommon.parser_base_path = File.dirname(__FILE__) + '/tmp'
  end

  after do
    FileUtils.rmdir(SupplejackCommon.parser_base_path)
  end

  describe '#path' do
    it 'builds a absolute path to the temp file' do
      loader.path.should eq "#{File.dirname(__FILE__)}/tmp/json/europeana.rb"
    end

    it 'memoizes the path' do
      parser.should_receive(:file_name).once { '/path' }
      loader.path
      loader.path
    end
  end

  describe '#content_with_encoding' do
    it 'should add a utf-8 encoding to the top of the file' do
      loader.content_with_encoding.should eq "# encoding: utf-8\r\nmodule LoadedParser::Staging\nclass Europeana < SupplejackCommon::Json::Base; end\nend"
    end
  end

  describe '#create_tempfile' do
    it 'creates a new tempfile with the path' do
      loader.create_tempfile
      File.read(loader.path).should eq "# encoding: utf-8\r\nmodule LoadedParser::Staging\nclass Europeana < SupplejackCommon::Json::Base; end\nend"
    end
  end

  describe '#parser_class_name' do
    it 'removes whitespace from the name' do
      parser.stub(:name) { 'NatLib Pages' }
      loader.parser_class_name.should eq 'NatLibPages'
    end

    it 'capitalizes each word' do
      parser.stub(:name) { 'nlnzcat catalog' }
      loader.parser_class_name.should eq 'NlnzcatCatalog'
    end
  end

  describe '#parser_class_name_with_module' do
    it 'removes whitespace from the name' do
      parser.stub(:name) { 'NatLib Pages' }
      loader.parser_class_name_with_module.should eq 'LoadedParser::Staging::NatLibPages'
    end

    it 'capitalizes each word' do
      parser.stub(:name) { 'nlnzcat catalog' }
      loader.parser_class_name_with_module.should eq 'LoadedParser::Staging::NlnzcatCatalog'
    end
  end

  describe '#parser_class' do
    before(:each) do
      loader.load_parser
    end

    it 'returns the class singleton' do
      loader.parser_class.should eq LoadedParser::Staging::Europeana
    end
  end

  describe '#load_parser' do
    it 'creates the tempfile' do
      loader.should_receive(:create_tempfile)
      loader.load_parser
    end

    it 'clears the klass definitions' do
      loader.should_receive(:clear_parser_class_definitions)
      loader.load_parser
    end

    it 'loads the file' do
      loader.should_receive(:load).with(loader.path)
      loader.load_parser.should be_true
    end
  end

  describe 'loaded?' do
    it 'loads the parser file' do
      loader.should_receive(:load_parser)
      loader.loaded?
    end

    it 'returns the @loaded value' do
      loader.instance_variable_set('@loaded', true)
      loader.loaded?.should be_true
    end
  end

  describe 'clear_parser_class_definitions' do
    before(:each) do
      loader.load_parser
    end

    it 'clears the parser class definitions' do
      LoadedParser::Staging::Europeana.should_receive(:clear_definitions)
      loader.clear_parser_class_definitions
    end
  end
end
