require "spec_helper"

describe HarvesterCore::Utils do
  
  let(:mod) { HarvesterCore::Utils }

  let(:xml) do
    <<-XML
<?xml version='1.0' encoding='UTF-8'?>
<feed xmlns='http://www.w3.org/2005/Atom' xmlns:media='http://search.yahoo.com/mrss/'>
<title type='text'>Videos</title>
<author><name>YouTube</name></author>
</feed>
    XML
  end

  describe "#remove_default_namespace" do
    it "removes the default namespace" do
      new_xml = mod.remove_default_namespace(xml)
      new_xml.should eq <<-XML
<?xml version='1.0' encoding='UTF-8'?>
<feed xmlns:media='http://search.yahoo.com/mrss/'>
<title type='text'>Videos</title>
<author><name>YouTube</name></author>
</feed>
      XML
    end

    it "returns the same xml" do
      mod.remove_default_namespace("<author><name>YouTube</name></author>").should eq "<author><name>YouTube</name></author>"
    end
  end
end