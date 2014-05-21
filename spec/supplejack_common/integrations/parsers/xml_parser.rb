# The Supplejack Common code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack_core 

class XmlParser < SupplejackCommon::Xml::Base
  base_url "http://digitalnz.org/xml"

  namespaces       g: "http://digitalnz.org/schemas/test", 
              person: "http://schema.org/Person", 
                  dc: "http://digitalnz.org/schemas/dc"

  record_selector "/g:items/g:item"

  record_format :xml

  attribute :content_partner,         default: "NZ On Screen"

  attribute :title,                   xpath: "/g:title"
  attribute :description,             xpath: "//g:description"
  attribute :date,                    xpath: "/dc:date"

  attribute :display_date do
    fetch('/dc:date')   
  end

  attribute :author,                  xpath: "/person:author/person:name"
end