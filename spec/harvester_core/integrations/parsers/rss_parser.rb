# The Supplejack code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack_core 

class RssParser < HarvesterCore::Rss::Base
  
  base_url "http://www.library.org/records"

  attribute :title,                   xpath: "//title"
  attribute :description,             xpath: "//description"
  attribute :date,                    xpath: "//pubDate", date: true
  attribute :landing_url,             xpath: "//guid"

  attribute :thumbnail_url, xpath: "//enclosure/@url"

  attribute :category,                default: ["Newspapers"] do
    get(:category).add("Images") if get(:thumbnail_url).present?
  end

  attribute :large_thumbnail_url do
    get(:thumbnail_url).mapping(/width=[\d]{1,4}/ => "width=520")
  end
end