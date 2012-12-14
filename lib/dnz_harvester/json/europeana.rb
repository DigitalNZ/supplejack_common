class Europeana < DnzHarvester::Json::Base
  
  # Some questions:
  # - Whats the consequence of huge titles? http://api.europeana.eu/api/opensearch.json?searchTerms=%22new+zealand%22&wskey=NEEIVFPGTW&startPage=125
  
  base_url "http://api.europeana.eu/api/opensearch.json?searchTerms=%22new+zealand%22&wskey=NEEIVFPGTW"
  record_selector "$..items"

  attribute  :archive_title,       	  		                            default: "europeana"
  attributes :display_content_partner, :content_partner,       	  		default: "Europeana"
  attributes :display_collection, :primary_collection, :collection,		default: "Europeana"
  
  attributes :identifier, :landing_url,   path: "guid"
  attribute  :title,                   		path: "title"
  attribute  :description,             		path: "description"
  # attribute  :thumbnail_url,          	 	path: "enclosure" do
  #   compose("http://europeanastatic.eu/api/image?type=IMAGE&uri=", get(:thumbnail_url).encode)
  # end
  attribute  :creator,                 		path: "dc:creator"
  attribute  :subject,                 		path: "dc:subject"
  attribute  :language,                		path: "europeana:language"
  attribute  :dc_rights,                 	path: "europeana:rights"
  attribute  :dc_type,                 		path: "europeana:type"
  attribute  :is_part_of,                 path: "dcterms:isPartOf"
  attribute  :dc_date,                 		path: "enrichment:period_label", date: true
  attribute  :display_date,               path: "enrichment:period_label"
  
  attribute  :rights_url do
    get(:dc_rights).find_with("http")
  end
   
  attribute  :contributing_partner,    		path: ["europeana:dataProvider", "europeana:provider"], join: ", "
    
  attribute :category do
    # case get(:dc_type)
    # when "IMAGE" then "Images"
    # when "VIDEO" then "Videos"
    # when "AUDIO" then "Audio"
    # when "TEXT"  then "Research papers"
    # else
    #   "Other"
    # end
  end
  
  # need to implement some rights solution
  #
  #    for rights, copyright, license
  # 
  # and hopefully make as re-usable as possible
  
  def locations
    # [{
    #   lat: fetch("place_latitude"),
    #   lng: fetch("place_longitude"),
    # }]
  end
  
  # something to enable rejecting records based on a criteria
  # def reject_record
  #   get(:dc_rights).reject_record if find(/\/rr-r\//)
  # end
end