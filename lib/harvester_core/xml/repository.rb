# encoding: UTF-8

class Repositoy < HarvesterCore::Xml::Base
  
  base_url "http://repository.digitalnz.org/public_records.xml"
  # record_selector "//records/record"

  attribute  :archive_title,       	  								              default: "repository"
  attribute  :no_landing_page,         								              default: true
  attributes :collection, :display_collection, :primary_collection, default: "Shared Repository"
  
  attribute  :dc_type,      				      xpath: "//record-type"
  attributes :identifier, :dc_identifier,	xpath: "//id"
  attributes :coverage, :placename,			  xpath: "//places-covered"
  attribute  :title,                  		xpath: "//title"
  attribute  :description,                xpath: "//description"
  attribute  :relation,                  	xpath: "//relation"
  attribute  :subject,                		xpath: "//subject",   separator: ","
  attribute  :date,          				      xpath: "//date",      date: true
  attribute  :display_date,          		  xpath: "//date",      date: "%d/%m/%Y"
  attribute  :peer_reviewed,              xpath: "//status"

  attributes :content_partner, :display_content_partner, :publisher,	xpath: "//organisation" do
    get(:content_partner).find_and_replace(/^Archives New Zealand Te Rua Mahara o te.*$/ => 'Archives New Zealand Te Rua Mahara o te Kāwanatanga')
  end
  
  # def landing_url
    # has no www landing page so we use the dnz details.
	# So it needs to point back at itself ie "http://www.digitalnz.org/records/{recordnumber}"
  # end

  attribute :category, xpath: "//record-type", mapping: {
                          /^(Still Image)$/ => "Images",
                          /^(Sound)$/ => "Audio",
                          /^(General|Physical Object|Collection|Event|Service|Software)$/ => "Other",
                          /^(Text|Scholarly Text|Book Item|Conference Item|Journal Item|Journal Article|Report)$/ => "Research papers",
                          /^(Moving Image)$/ => "Videos",
                          /^(Book item)$/ => "Books",
                          /^(Interactive Resource|Inter Active item)$/ => "Images",
                          /^(Dataset)$/ => "Data",
                          // => "Other"
                        }

  # def attachments
  #   return [] unless fetch("//state") == "published"
  #   [{
  #     url: fetch("//url"),
  #     name: fetch("//attachment"),
  #   }]
  # end

  # def object_url
  #   return [] unless fetch("//state") == "published"
  #   fetch("//url")
  # end
  
  # def contributor
  #   get(:subject) + fetch("//funding-provider").find_all_without(/^(Other|None)$/)
  # end
	  
  # def set_rights
	  # some kind of method to bulk set all the rights fields based on various values
	  # This case is quite complicated based on //rights, //rights_url, and //license
	  # it also has some hardcoded parts for certain organisations (ie CHRANZ is all rights reserved)
  # end

  # something to enable rejecting records based on a criteria
  # def reject_record
    # reject_record if get(:content_partner).find_without(/(UCOL Universal College of Learning)|(Whitireia Community Polytechnic)|(Wellington City Council)|(Eastern Institute of Technology)|(Centre for Housing Research Aotearoa New Zealand\s*)|(Archives New Zealand Te Rua Mahara o te K.wanatanga)|(SPARC)|(Productivity Commission)|(Department of Building and Housing)/)
  # end

end