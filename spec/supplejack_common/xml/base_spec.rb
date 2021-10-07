# frozen_string_literal: true

require 'spec_helper'

describe SupplejackCommon::Xml::Base do
  let(:document) { mock(:document) }

  after { described_class.clear_definitions }

  describe '.record_selector' do
    it 'assignes the record selector xpath class attributed' do
      described_class.record_selector('//o:ListRecords/o:record')
      expect(described_class._record_selector).to eq '//o:ListRecords/o:record'
    end
  end

  describe '.next_page_token' do
    it 'returns the next page token from the document of xml' do
      described_class._document = Nokogiri::XML.parse '<NextPageToken>token</NextPageToken>'
      expect(described_class.next_page_token('//NextPageToken')).to eq 'token'
    end
  end

  describe '.records' do
    it 'returns an object of type SupplejackCommon::Sitemap::PaginatedCollection when sitemap_entry_selector is set' do
      described_class.should_receive(:_sitemap_entry_selector).twice.and_return('//loc')
      described_class.records.class.should eq SupplejackCommon::Sitemap::PaginatedCollection
    end

    it 'returns an object of type SupplejackCommon::PaginatedCollection when sitemap_entry_selector is set' do
      described_class.should_receive(:_sitemap_entry_selector).and_return(nil)
      described_class.records.class.should eq SupplejackCommon::PaginatedCollection
    end
  end

  describe '.record_format' do
    it 'stores the format of the actual record' do
      described_class.record_format :xml
      described_class._record_format.should eq :xml
    end
  end

  describe '.record_selector' do
    it 'stores the xpath to retrieve every record' do
      described_class.record_selector '//items/item'
      described_class._record_selector.should eq '//items/item'
    end
  end

  describe '.fetch_records' do
    it 'initializes a set of xml records' do
      described_class.should_receive(:xml_records).with(nil) { [] }
      described_class.fetch_records
    end
  end

  describe '.clear_definitions' do
    it 'clears the record_selector' do
      described_class.record_selector '//item'
      described_class.clear_definitions
      described_class._record_selector.should be_nil
    end

    it 'clears the total results' do
      described_class._total_results = 100
      described_class.clear_definitions
      described_class._total_results.should be_nil
    end
  end

  describe '#initialize' do
    it 'initializes a sitemap record' do
      record = described_class.new(nil, 'http://google.com/1.html')
      record.url.should eq 'http://google.com/1.html'
    end

    it 'initializes a xml record' do
      node = mock(:node, to_xml: '<record></record>')
      record = described_class.new(node)
      record.document.should eq node
    end

    it 'initializes from raw xml' do
      xml = '<record></record>'
      record = described_class.new(xml, nil, true)
      record.original_xml.should eq xml
    end
  end

  describe '#format' do
    context 'sitemap records' do
      it 'defaults to HTML' do
        described_class.new(nil, 'http://google.com/1').format.should eq :html
      end

      it 'returns XML when format is explicit at the described_class level' do
        described_class.record_format :xml
        described_class.new(nil, 'http://google.com/1').format.should eq :xml
      end
    end

    context 'records from single XML' do
      it 'default to XML for a raw record' do
        described_class.new(nil, '<record/>', true).format.should eq :xml
      end

      it 'returns HTML when format is explicit for raw records' do
        described_class.record_format :html
        described_class.new(nil, '<body/>', true).format.should eq :html
      end
    end
  end

  describe '#url' do
    before do
      described_class.any_instance.stub(:set_attribute_values) { nil }
    end

    let(:record) { described_class.new(nil, 'http://google.com') }

    it 'returns the url' do
      record.url.should eq 'http://google.com'
    end

    it 'returns the url with basic auth values' do
      described_class.basic_auth 'username', 'password'
      record.url.should eq 'http://username:password@google.com'
    end
  end

  describe '#document' do
    before do
      described_class.any_instance.stub(:set_attribute_values) { nil }
    end

    let(:document) { mock(:document) }
    let(:record) { described_class.new(nil, 'http://google.com') }

    context 'format is XML' do
      let(:xml) { '<record>Some xml data</record>' }

      before do
        record.stub(:format) { :xml }
        SupplejackCommon::Request.stub(:get) { xml }
        SupplejackCommon::Utils.stub(:remove_default_namespace).with(xml) { xml }
      end

      it 'requets a record and removes the default namespace' do
        SupplejackCommon::Request.should_receive(:get) { xml }
        Nokogiri::XML.should_receive(:parse).with(xml) { document }
        record.document.should eq document
      end

      it 'should not add a HTML tag' do
        SupplejackCommon::Utils.should_not_receive(:add_html_tag)
        record.document
      end

      it 'builds a document from original_xml' do
        record = described_class.new('<record>other data</record>', nil, true)
        record.document.to_xml.should eq "<?xml version=\"1.0\"?>\n<record>other data</record>\n"
      end
    end

    context 'format is HTML' do
      let(:html) { '<html>Some data</html>' }

      before do
        record.stub(:format) { :html }
        SupplejackCommon::Request.stub(:get) { html }
      end

      it 'parses the requested HTML' do
        SupplejackCommon::Request.should_receive(:get) { html }
        record.document
      end

      it 'should parse the HTML document' do
        Nokogiri::HTML.should_receive(:parse).with('<html>Some data</html>')
        record.document
      end
    end
  end

  describe 'raw_data' do
    # rubocop:disable all
    let(:xml) do
      <<-XML
<?xml version="1.0"?>
<document>
<item><title>Hi</title></item>
<item><title>Hi2</title></item>
</document>
XML
    # rubocop:enable
    end
    let(:document) { Nokogiri::XML.parse(xml) }

    context 'full xml document' do
      let(:record) { described_class.new('http://google.com/1') }

      before(:each) do
        record.stub(:document) { document }
      end

      it 'returns the full xml document' do
        record.raw_data.should eq(xml)
      end
    end

    context 'node within xml document' do
      let(:record) { described_class.new(document.xpath('//item').first) }

      it 'returns the snippet corresponding to the record' do
        record.raw_data.should eq("<item>
  <title>Hi</title>
</item>")
      end
    end
  end
end
