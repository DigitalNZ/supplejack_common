class AucklandUniLibrary < DnzHarvester::Oai::Base
  
  base_url "https://researchspace.auckland.ac.nz/dspace-oai/request"

  attribute :archive_title,           default: "auck-uni-libraries-oai"
  attribute :category,                default: "Research papers"
  attribute :content_partner,         default: ["The University of Auckland Library"]
  attribute :display_content_partner, default: "The University of Auckland Library"
  attribute :collection,              default: ["ResearchSpace@Auckland", "Kiwi Research Information Service"]

  attribute :title,         from: "dc:title"
  attribute :subject,       from: "dc:subject"
  attribute :description,   from: "dc:description"   
  attribute :date,          from: "dc:date"
  attribute :dc_type,       from: "dc:type"
  attribute :dc_identifier, from: "dc:identifier"
  attribute :language,      from: "dc:language"
  attribute :relation,      from: "dc:relation"
  attribute :rights,        from: "dc:rights"

  enrich :citation,         xpath: "//table/tr", if: {"td[1]" => "dc.identifier.citation"}, value: "td[2]"

  #A: could these be more semantic?
  #   for example:
  #   
  #   custom_attribute :identifier do 
  #     find_without(/http/).within(:identifier)
  #   end
  def identifier
    find_without(/http/).within(:identifier)
  end

  def landing_url
    find_with(/http/).within(:identifier)
  end

  def description
    last(:description)
  end

  #A: this isn't really an attribute, it's required configuration for
  #   enriched attributes, like base_url
  #
  #   enrichment_url do
  #     find_and_replace(/.*handle.net(.*)/, 'https://researchspace.auckland.ac.nz/handle\1?show=full').within(:dc_identifier)
  #   end
  #
  #   enrich_attribute :citation,         xpath: "table/tr", if: {"td[1]" => "dc.identifier.citation"}, value: "td[2]"

  def enrichment_url
    find_and_replace(/.*handle.net(.*)/, 'https://researchspace.auckland.ac.nz/handle\1?show=full').within(:dc_identifier)
  end
end