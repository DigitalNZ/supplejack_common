class Europeana < DnzHarvester::Json::Base
  
  base_url "http://api.europeana.eu/api/opensearch.json?searchTerms=%22new+zealand%22&wskey=NEEIVFPGTW"
  record_selector "$..items"

  attribute :identifier,              path: "guid"
  attribute :title,                   path: "title"
  attribute :description,             path: "description"
  attribute :landing_url,             path: "link" do
    find_and_replace(/.*record\/(\w+)\/(\w+).*/, 'http://www.europeana.eu/portal/record/\1/\2').within(:landing_url)
  end
  attribute :thumbnail_url,           path: "enclosure"
  attribute :creator,                 path: "dc:creator"
  attribute :year,                    path: "europeana:year"
  attribute :language,                path: "europeana:language"
  attribute :dnz_type,                path: "europeana:type"
  attribute :contributing_partner,    path: "europeana:dataProvider"

end