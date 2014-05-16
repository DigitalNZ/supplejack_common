# The Supplejack code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack_core 

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