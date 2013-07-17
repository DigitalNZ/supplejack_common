class XmlTarParser < HarvesterCore::Xml::Base
  base_url "file://spec/harvester_core/integrations/source_data/tared_xml.tar.gz"

  namespaces       g: "http://digitalnz.org/schemas/test", 
              person: "http://schema.org/Person", 
                  dc: "http://digitalnz.org/schemas/dc"

  record_selector "/item"

  record_format :xml

  attribute :content_partner,         default: "NZ On Screen"

  attribute :title,                   xpath: "/title"
end