# frozen_string_literal: true

require 'spec_helper'

describe SupplejackCommon::Xml::Base do
  let(:document) { double(:document) }

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
      expect(described_class).to receive(:_sitemap_entry_selector).twice.and_return('//loc')
      expect(described_class.records.class).to eq SupplejackCommon::Sitemap::PaginatedCollection
    end

    it 'returns an object of type SupplejackCommon::PaginatedCollection when sitemap_entry_selector is set' do
      expect(described_class).to receive(:_sitemap_entry_selector).and_return(nil)
      expect(described_class.records.class).to eq SupplejackCommon::PaginatedCollection
    end
  end

  describe '.record_format' do
    it 'stores the format of the actual record' do
      described_class.record_format :xml
      expect(described_class._record_format).to eq :xml
    end
  end

  describe '.record_selector' do
    it 'stores the xpath to retrieve every record' do
      described_class.record_selector '//items/item'
      expect(described_class._record_selector).to eq '//items/item'
    end
  end

  describe '.fetch_records' do
    it 'initializes a set of xml records' do
      expect(described_class).to receive(:xml_records).with(nil) { [] }
      described_class.fetch_records
    end
  end

  describe '.clear_definitions' do
    it 'clears the record_selector' do
      described_class.record_selector '//item'
      described_class.clear_definitions
      expect(described_class._record_selector).to be_nil
    end

    it 'clears the total results' do
      described_class._total_results = 100
      described_class.clear_definitions
      expect(described_class._total_results).to be_nil
    end
  end

  describe '#initialize' do
    it 'initializes a sitemap record' do
      record = described_class.new(nil, 'http://google.com/1.html')
      expect(record.url).to eq 'http://google.com/1.html'
    end

    it 'initializes a xml record' do
      node = double(:node, to_xml: '<record></record>')
      record = described_class.new(node)
      expect(record.document).to eq node
    end

    it 'initializes from raw xml' do
      xml = '<record></record>'
      record = described_class.new(xml, nil, true)
      expect(record.original_xml).to eq xml
    end
  end

  describe '#format' do
    context 'sitemap records' do
      it 'defaults to HTML' do
        expect(described_class.new(nil, 'http://google.com/1').format).to eq :html
      end

      it 'returns XML when format is explicit at the described_class level' do
        described_class.record_format :xml
        expect(described_class.new(nil, 'http://google.com/1').format).to eq :xml
      end
    end

    context 'records from single XML' do
      it 'default to XML for a raw record' do
        expect(described_class.new(nil, '<record/>', true).format).to eq :xml
      end

      it 'returns HTML when format is explicit for raw records' do
        described_class.record_format :html
        expect(described_class.new(nil, '<body/>', true).format).to eq :html
      end
    end
  end

  describe '#url' do
    before do
      allow_any_instance_of(described_class).to receive(:set_attribute_values) { nil }
    end

    let(:record) { described_class.new(nil, 'http://google.com') }

    it 'returns the url' do
      expect(record.url).to eq 'http://google.com'
    end

    it 'returns the url with basic auth values' do
      described_class.basic_auth 'username', 'password'
      expect(record.url).to eq 'http://username:password@google.com'
    end
  end

  describe '#document' do
    before do
      allow_any_instance_of(described_class).to receive(:set_attribute_values) { nil }
    end

    let(:document) { double(:document) }
    let(:record) { described_class.new(nil, 'http://google.com') }

    context 'format is XML' do
      let(:xml) { '<record>Some xml data</record>' }

      before do
        allow(record).to receive(:format) { :xml }
        allow(SupplejackCommon::Request).to receive(:get) { xml }
        allow(SupplejackCommon::Utils).to receive(:remove_default_namespace).with(xml) { xml }
      end

      it 'requets a record and removes the default namespace' do
        expect(SupplejackCommon::Request).to receive(:get) { xml }
        expect(Nokogiri::XML).to receive(:parse).with(xml) { document }
        expect(record.document).to eq document
      end

      it 'should not add a HTML tag' do
        expect(SupplejackCommon::Utils).not_to receive(:add_html_tag)
        record.document
      end

      it 'builds a document from original_xml' do
        record = described_class.new('<record>other data</record>', nil, true)
        expect(record.document.to_xml).to eq "<?xml version=\"1.0\"?>\n<record>other data</record>\n"
      end
    end

    context 'format is HTML' do
      let(:html) { '<html>Some data</html>' }

      before do
        allow(record).to receive(:format) { :html }
        allow(SupplejackCommon::Request).to receive(:get) { html }
      end

      it 'parses the requested HTML' do
        expect(SupplejackCommon::Request).to receive(:get) { html }
        record.document
      end

      it 'should parse the HTML document' do
        expect(Nokogiri::HTML).to receive(:parse).with('<html>Some data</html>')
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
        allow(record).to receive(:document) { document }
      end

      it 'returns the full xml document' do
        expect(record.raw_data).to eq(xml)
      end
    end

    context 'node within xml document' do
      let(:record) { described_class.new(document.xpath('//item').first) }

      it 'returns the snippet corresponding to the record' do
        expect(record.raw_data).to eq("<item>
  <title>Hi</title>
</item>")
      end
    end
  end
end
