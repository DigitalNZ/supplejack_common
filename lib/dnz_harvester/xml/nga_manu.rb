class NgaManu < DnzHarvester::Xml::Base
  
  base_url "http://dl.dropbox.com/u/63489205/imgmap.xml"
  record_selector "//items/item"

  attribute  :archive_title,       	  								               default: "nga-manu-xml"
  attribute  :category,               								               default: "Images"
  attributes :content_partner, :display_content_partner,     		     default: "Nga Manu Nature Reserve"
  attributes :collection, :display_collection, :primary_collection,  default: "Nga Manu Images"
  
  attributes :identifier, :object_url,		xpath: "//img_url"
  attribute  :title,                  		xpath: "//title"
  attribute  :description,                xpath: "//description" do
    compose(get(:description), "Creative Commons BY NC 3.0 NZ", separator: " ")
  end
  attribute  :creator,                  	xpath: "//creator"
  attribute  :subject,                		xpath: "//categoryName"
  attribute  :dc_date,                		xpath: "//objectDate", date: true
  attribute  :display_date,           		xpath: "//objectDate"

  # def landing_url
    # has no www landing page so we use the dnz details.
	# So it needs to point back at itself ie "http://www.digitalnz.org/records/{recordnumber}"
  # end
  
  attribute :dc_identifier do
    get(:identifier).find_and_replace(/^.*\/([^\/\.]*)\.\w+\s*$/ => '\1')
  end
  
  attribute :thumbnail_url do
    get(:identifier).find_and_replace(/\/([^\/]*\.\w*)$/ => '/sm_\1')
  end
  
  attribute :large_thumbnail_url do
    get(:identifier).find_and_replace(/\/([^\/]*\.\w*)$/ => '/lg_\1')
  end
  
  # def rights
	  # some kind of method to bulk declare all the rights fields (in cases where it is possible).
	  # could be a separate method for hardcoding and dynamic (ie values based on creative commons urls in the metadata)
	  # In this case all records are to be hard coded to "all rights reserved" 
	  # so copyright and usage need to be set to "All rights reserved"
	  # In other cases all records may be hardcoded to CC-BY which would set various values in copyright, usage, license, and rights_url  
  # end

  # def description
  #   description = xpath("objectDescription")
  #   category = fetch("//categoryName").present? ? "Category: #{fetch("//categoryName")}" : nil
  #   classification = fetch("//objectClassification").present? ? "Classification: #{fetch("//objectClassification")}" : nil
  #   location = fetch("//objectLocation").present? ? "Location: #{fetch("//objectLocation")}" : nil
    
  #   compose(description, category, classification, location, separator: ", ")
  # end

end