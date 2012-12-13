class Europeana < DnzHarvester::Json::Base
  
  # Some questions:
  # - Whats the consequence of huge titles? http://api.europeana.eu/api/opensearch.json?searchTerms=%22new+zealand%22&wskey=NEEIVFPGTW&startPage=125
  
  base_url "http://api.europeana.eu/api/opensearch.json?searchTerms=%22new+zealand%22&wskey=NEEIVFPGTW"
  record_selector "$..items"

  attribute  :archive_title,       	  		default: "europeana"
  attributes :display_content_partner, :content_partner,       	  		default: "Europeana"
  attributes :display_collection, :primary_collection, :collection,		default: "Europeana"
  
  attributes :identifier, :landing_url,     path: "guid"
  attribute  :title,                   		path: "title"
  attribute  :description,             		path: "description"
  attribute  :thumbnail_url,          	 	path: "enclosure"
  attribute  :creator,                 		path: "dc:creator"
  attribute  :subject,                 		path: "dc:subject"
  attribute  :language,                		path: "europeana:language"
  attribute  :dc_rights,                 	path: "europeana:rights"
  attribute  :dc_type,                 		path: "europeana:type"
  attribute  :is_part_of,                   path: "dcterms:isPartOf"
  attribute  :dc_date,                 		path: "enrichment:period_label", date: true
  attribute  :display_date,                 path: "enrichment:period_label"
  
  attribute  :rights_url, do
    find_with("http").within(:dc_rights)
  end
   
  # Here the dataProvider and provider fields should be joint with a ", " in the middle.
  attribute  :contributing_partner,    		path: ["europeana:dataProvider", "europeana:provider"], join_with: ", "
  
  # Not sure how to do this one. Need to get thumbnail_url from path: "enclosure"
  # URL encode it
  # then put it on the end of http://europeanastatic.eu/api/image?type=IMAGE&uri=
  # used to look something like http://europeanastatic.eu/api/image?type=IMAGE&amp;amp;uri={ encode-for-uri(data($node/@url)) }
    
  def category
    return "Images" if original_attributes[:dc_type] == "IMAGE"
    return "Videos" if original_attributes[:dc_type] == "VIDEO"
    return "Audio" if original_attributes[:dc_type] == "AUDIO"
    return "Research papers" if original_attributes[:dc_type] == "TEXT"
    return "Other"
  end
  
  # need to implement some rights solution
  #
  #    for rights, copyright, license
  # 
  # and hopefully make as re-usable as possible
  
  def locations
    [{
      lat: path: "place_latitude",
      lng: path: "place_longitude",
    }]
  end
  
  # something to enable rejecting records based on a criteria
  def reject_record
    reject_record if find(/\/rr-r\//).within(:dc_rights)
  end
end