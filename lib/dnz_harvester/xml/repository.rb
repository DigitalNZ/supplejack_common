class Repositoy < DnzHarvester::Xml::Base
  
  base_url "http://repository.digitalnz.org/public_records.xml"
  record_url_selector "//records/record"

  attribute  :archive_title,       	  								default: "repository"
  attribute  :category,               								default: "Images"
  attribute  :no_landing_page,         								default: "true"
  attributes :collection, :display_collection, :primary_collection, default: "Shared Repository"
  
  attribute  :dc_type,      				xpath: "//record-type"
  attributes :identifier, :dc_identifier,	xpath: "//id"
  attributes :coverage, :placename,			xpath: "//places-covered"
  attribute  :title,                  		xpath: "//title"
  attribute  :description,                  xpath: "//description"
  attribute  :relation,                  	xpath: "//relation"
  attribute  :subject,                		xpath: "//subject", separator: ",\s?"
  attribute  :date,          				xpath: "//date", date: true
  attribute  :display_date,          		xpath: "//date", date: "%d/%m/%Y"
  attribute  :peer_reviewed,               	xpath: "//status"
  
  # some of these organisations have a space at the end that needs to be stripped
  # also the first 'a' in Kawanatanga need to have a line above it
  attributes :content_partner, :display_content_partner, :publisher,	xpath: "//organisation" do
    find_and_replace(/^Archives New Zealand Te Rua Mahara o te.*$/, 'Archives New Zealand Te Rua Mahara o te Kawanatanga').within(:identifier)
  end
  
  # def landing_url
    # has no www landing page so we use the dnz details.
	# So it needs to point back at itself ie "http://www.digitalnz.org/records/{recordnumber}"
  # end
  
  def category
    return "Images" if original_attributes[:dc_type] == "Still Image"
    return "Audio" if original_attributes[:dc_type] == "Sound"
    return "Other" if original_attributes[:dc_type] == ("General" or "Physical Object" or "Collection" or "Event" or "Service" or "Software")
    return "Research papers" if original_attributes[:dc_type] == ("Text" or "Scholarly Text" or "Book Item" or "Conference Item" or "Journal Item" or "Journal Article" or "Report")
    return "Videos" if original_attributes[:dc_type] == "Moving Image"
    return "Books" if original_attributes[:dc_type] == "Book item"
    return "Images" if original_attributes[:dc_type] == ("Interactive Resource" or "Inter Active item")
    return "Data" if original_attributes[:dc_type] == "Dataset"
    return "Other"
  end  
  
  # only returns the attachment if the //state is published
  # also there can be "'s (quote marks) in the name (//attachments)
  # def attachments
    # return [{
      # url: xpath: "//url",
      # name: xpath: "//attachment",
    # }] if xpath: "//state" == "published"
  # end

  def object_url
    return xpath: "//url" if xpath: "//state" == "published"
  end
  
  # append the values from these xpaths
  # def contributor
    # return append: 
	# [
	  # xpath: "//subject", separator: " / ",
	  # xpath: "//funding-provider" unless xpath: "//funding-provider" == ("Other", "None")
	# ]
  # end
	  
  # def set_rights
	  # some kind of method to bulk set all the rights fields based on various values
	  # This case is quite complicated based on //rights, //rights_url, and //license
	  # it also has some hardcoded parts for certain organisations (ie CHRANZ is all rights reserved)
  # end

  # something to enable rejecting records based on a criteria
  # def reject_record
    # reject_record if find_without(/(UCOL Universal College of Learning)|(Whitireia Community Polytechnic)|(Wellington City Council)|(Eastern Institute of Technology)|(Centre for Housing Research Aotearoa New Zealand\s*)|(Archives New Zealand Te Rua Mahara o te K.wanatanga)|(SPARC)|(Productivity Commission)|(Department of Building and Housing)/).within(:content_partner)
  # end

end