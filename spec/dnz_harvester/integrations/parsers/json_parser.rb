class JsonParser < DnzHarvester::Json::Base
  
  base_url "http://api.europeana.eu/records.json"
  record_selector "$..items"

  attribute :collection,              default: "Europeana"

  attribute :identifier,              path: "guid"
  attribute :title,                   path: "title"
  attribute :description,             path: "description"
  attribute :landing_url,             path: "link"
  attribute :thumbnail_url,           path: "enclosure"
  attribute :creator,                 path: "dc:creator"
  attribute :year,                    path: "europeana:year"
  attribute :language,                path: "europeana:language"
  attribute :dnz_type,                path: "europeana:type"
  attribute :contributing_partner,    path: "europeana:dataProvider"

  def landing_url
    find_and_replace(/.*record\/(\w+)\/(\w+).*/, 'http://www.europeana.eu/portal/record/\1/\2').within(:landing_url)
  end
end