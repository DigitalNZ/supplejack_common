require_relative 'base'

class AucklandUniLibrary < Harvester::Oai::Base
  
  base_url "http://researchspace.auckland.ac.nz/dspace-oai/request"

  default :archive_title,           "auck-uni-libraries-oai"
  default :category,                "Research papers"
  default :content_partner,         ["The University of Auckland Library"]
  default :display_content_partner, "The University of Auckland Library"
  default :collection,              ["ResearchSpace@Auckland", "Kiwi Research Information Service"]

  def identifier
    find_without(/http/).within(:identifier)
  end

  def landing_url
    find_with(/http/).within(:identifier)
  end

  def description
    last(:description)
  end
end