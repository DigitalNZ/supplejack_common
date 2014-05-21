# The Supplejack Common code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack 

class XmlSitemapParser < SupplejackCommon::Xml::Base
  
  base_url "http://www.nzonscreen.com/api/title/"

  namespaces dc: 'http://purl.org/dc/elements/1.1/'

  sitemap_entry_selector "//loc"
  record_selector "//title"

  record_format :xml

  attribute :content_partner,         default: "NZ On Screen"
  attribute :category,                default: "Videos"

  attribute :title,                   xpath: "//title/name"
  attribute :description,             xpath: "//synopsis"
  attribute :date,                    xpath: "//dc:date"

  attribute :tag,                     xpath: "//tags", separator: ","
  attribute :thumbnail_url,           xpath: "//thumbnail-image/title/path"

  attribute :contributor,             xpath: "//person", object: true do
    if get(:contributor).present?
      get(:contributor).to_a.map do |person|
        first_name = person.xpath("first-name")
        last_name = person.xpath("last-name")
        [first_name, last_name].join(" ")
      end
    end
  end
end