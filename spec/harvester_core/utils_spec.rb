require "spec_helper"

describe HarvesterCore::Utils do
  
  let(:mod) { HarvesterCore::Utils }

  describe "#remove_default_namespace" do
    let(:xml) do
      <<-XML
<?xml version='1.0' encoding='UTF-8'?>
<feed xmlns='http://www.w3.org/2005/Atom' xmlns:media='http://search.yahoo.com/mrss/'>
</feed>
      XML
    end

    it "removes the default namespace with single quotes" do
      new_xml = mod.remove_default_namespace(xml)
      new_xml.should eq <<-XML
<?xml version='1.0' encoding='UTF-8'?>
<feed xmlns:media='http://search.yahoo.com/mrss/'>
</feed>
      XML
    end

    it "removes the default namespace with double quotes" do
      xml_double_quotes = <<-XML
<?xml version='1.0' encoding='UTF-8'?>
<feed xmlns="http://www.w3.org/2005/Atom" xmlns:media='http://search.yahoo.com/mrss/'>
</feed>
    XML

      new_xml = mod.remove_default_namespace(xml_double_quotes)
      new_xml.should eq <<-XML
<?xml version='1.0' encoding='UTF-8'?>
<feed xmlns:media='http://search.yahoo.com/mrss/'>
</feed>
      XML
    end

    it "returns the same xml" do
      mod.remove_default_namespace("<author><name>YouTube</name></author>").should eq "<author><name>YouTube</name></author>"
    end
  end

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
end