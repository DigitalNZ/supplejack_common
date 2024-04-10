# frozen_string_literal: true

require 'spec_helper'

describe SupplejackCommon::Utils do
  let(:mod) { SupplejackCommon::Utils }

  describe 'add_html_tag' do
    let(:html) { '<div>Hi</div><span>You</span>' }

    it 'adds a html tag' do
      expect(mod.add_html_tag(html)).to eq '<html><div>Hi</div><span>You</span></html>'
    end

    context 'already has a html tag' do
      it "doesn't replace a simple html tag" do
        html = '<html><div>Hi</div></html>'
        expect(mod.add_html_tag(html)).to eq html
      end

      it "doesn't replace a html tag with simple doctype" do
        html = '<!DOCTYPE html><div>Hi</div></html>'
        expect(mod.add_html_tag(html)).to eq html
      end

      it "doesn't replace a html tag with complex doctype" do
        html = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"><div>Hi</div></html>'
        expect(mod.add_html_tag(html)).to eq html
      end
    end

    context 'it has a xml tag' do
      it "doesn't add a html tag" do
        xml = '<?xml version="1.0" encoding="UTF-8"?><title>Hi</title>'
        expect(mod.add_html_tag(xml)).to eq xml
      end
    end
  end

  describe '#add_namespaces' do
    let(:xml) { '<record>Hi</record>' }

    it 'should enclose the XML in a root node with the namespaces' do
      expect(mod.add_namespaces(xml, 'xmlns:media' => 'http://search.yahoo.com/mrss/')).to eq "<root xmlns:media='http://search.yahoo.com/mrss/'><record>Hi</record></root>"
    end
  end
end
