# The Supplejack code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack_core 

require "spec_helper"

describe HarvesterCore::Utils do
  
  let(:mod) { HarvesterCore::Utils }

  describe "add_html_tag" do
    let(:html) { "<div>Hi</div><span>You</span>" }

    it "adds a html tag" do
      mod.add_html_tag(html).should eq "<html><div>Hi</div><span>You</span></html>"
    end

    context "already has a html tag" do
      it "doesn't replace a simple html tag" do
        html = "<html><div>Hi</div></html>"
        mod.add_html_tag(html).should eq html
      end

      it "doesn't replace a html tag with simple doctype" do
        html = "<!DOCTYPE html><div>Hi</div></html>"
        mod.add_html_tag(html).should eq html
      end

      it "doesn't replace a html tag with complex doctype" do
        html = %q{<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"><div>Hi</div></html>}
        mod.add_html_tag(html).should eq html
      end
    end

    context "it has a xml tag" do
      it "doesn't add a html tag" do
        xml = %q{<?xml version="1.0" encoding="UTF-8"?><title>Hi</title>}
        mod.add_html_tag(xml).should eq xml
      end
    end
  end

  describe "#add_namespaces" do
    let(:xml) { "<record>Hi</record>" }

    it "should enclose the XML in a root node with the namespaces" do
      mod.add_namespaces(xml, "xmlns:media" => "http://search.yahoo.com/mrss/").should eq "<root xmlns:media='http://search.yahoo.com/mrss/'><record>Hi</record></root>"
    end
  end
end