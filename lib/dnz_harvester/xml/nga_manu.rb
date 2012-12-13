class NgaManu < DnzHarvester::Xml::Base
  
  base_url "http://dl.dropbox.com/u/63489205/imgmap.xml"
  record_url_selector "//items/item"

  attribute  :archive_title,       	  								default: "nga-manu-xml"
  attribute  :category,               								default: "Images"
  attributes :content_partner, :display_content_partner,     		default: "Nga Manu Nature Reserve"
  attributes :collection, :display_collection, :primary_collection, default: "Nga Manu Images"
  
  attributes :identifier, :object_url,		xpath: "//img_url"
  attribute  :title,                  		xpath: "//title"
  attribute  :description,                  xpath: "//description", append: " Creative Commons BY NC 3.0 NZ"
  attribute  :creator,                  	xpath: "//creator"
  attribute  :subject,                		xpath: "//categoryName"
  attribute  :dc_date,                		xpath: "//objectDate", get_date: "dc_date"
  attribute  :display_date,           		xpath: "//objectDate", get_date: "display_date"

  # def landing_url
    # has no www landing page so we use the dnz details.
	# So it needs to point back at itself ie "http://www.digitalnz.org/records/{recordnumber}"
  # end
  
  def dc_identifier
    find_and_replace(/^.*\/([^\/\.]*)\.\w+\s*$/, '\1').within(:identifier)
  end
  
  def thumbnail_url
    find_and_replace(/\/([^\/]*\.\w*)$/, '/sm_\1').within(:identifier)
  end
  
  def large_thumbnail_url
    find_and_replace(/\/([^\/]*\.\w*)$/, '/lg_\1').within(:identifier)
  end
  
  
  
  # This need to be appended together and spaces transformed to %20's, + there are many more mappings to come on this one!
  attribute :thumbnail_url,      ['http://www.omvirtuallythere.co.nz/objects/', xpath: "//catalogueID", xpath: "//objectName", '/thumb.jpg'],
								  mappings: {
									"\/Weta\/" => "/creepy/",
									"\/Ground Beetle\/" => "/Ground Beatle/",
									"\/Rutile\/" => "/Rutile-In-Quartz/"
								  }
  
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