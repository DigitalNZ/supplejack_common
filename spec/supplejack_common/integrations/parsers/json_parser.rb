# The Supplejack Common code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack_core 

class JsonParser < SupplejackCommon::Json::Base
  
  base_url "http://api.europeana.eu/records.json"
  record_selector "$.items"

  attribute :collection,              default: "Europeana"

  attribute :identifier,              path: "$.guid"
  attribute :title,                   path: "$.title"
  attribute :description,             path: "$.description", truncate: 21
  attribute :landing_url,             path: "$.link" do
    get(:landing_url).mapping(/.*record\/(\w+)\/(\w+).*/ => 'http://www.europeana.eu/portal/record/\1/\2')
  end
  attribute :thumbnail_url,           path: "$.enclosure"
  attribute :creator,                 path: "$.'dc:creator'"
  attribute :year,                    path: "$.'europeana:year'"
  attribute :language,                path: "$.'europeana:language'"
  attribute :dnz_type,                path: "$.'europeana:type'"
  attribute :contributing_partner,    path: "$.'europeana:dataProvider'"

  attribute :tags, path: "$.nested.things"
end