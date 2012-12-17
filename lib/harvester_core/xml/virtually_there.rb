class VirtuallyThere < HarvesterCore::Xml::Base
  
  base_url "file:///data/apps/harvester/resource_deployments/current/xml_files/virtually-there-xml.xml"
  # record_selector "//AllObjects"

  attribute  :archive_title,       	  						        default: "virtually-there"
  attribute  :category,               						        default: "Interactives"
  attribute  :collection,             						        default: ["Otago Museum Virtually There", "Matapihi"]
  attributes :content_partner, :display_content_partner,  default: "Otago Museum"
  attributes :display_collection, :primary_collection,		default: "Otago Museum Virtually There"
  
  attributes :landing_url, :identifier, 	xpath: "//URL"
  attribute  :title,                  		xpath: "//objectName"
  attribute  :dc_identifier,          		xpath: "//catalogueID"
  attribute  :subject,                		xpath: "//categoryName"
  attribute  :dc_date,                		xpath: "//objectDate", date: true
  attribute  :display_date,           		xpath: "//objectDate"

  # This need to be appended together and spaces transformed to %20's, + there are many more mappings to come on this one!
  # attribute :thumbnail_url do
  #   mapped_title = get(:title).find_and_replace(/Weta/ => 'creepy',
  #                                               /Ground Beetle/ => 'Ground Beatle',
  #                                               /Rutile/ => 'Rutile-In-Quartz')

  #   compose("http://www.omvirtuallythere.co.nz/objects/", get(:dc_identifier).select(:first), mapped_title, "/thumb.jpg")
  # end
  
  # def rights
	  # some kind of method to bulk declare all the rights fields (in cases where it is possible).
	  # could be a separate method for hardcoding and dynamic (ie values based on creative commons urls in the metadata)
	  # In this case all records are to be hard coded to "all rights reserved" 
	  # so copyright and usage need to be set to "All rights reserved"
	  # In other cases all records may be hardcoded to CC-BY which would set various values in copyright, usage, license, and rights_url  
  # end

  # def description
      # something like this that only appends each line if there is a corresponding xpath match. 
      # xpath("objectDescription"),
	  # ', Category:', xpath("//categoryName"),
	  # ', Classification:', xpath("//objectClassification"),
	  # ', Location:', xpath("//objectLocation"),
  # end

end