class OaiParser < HarvesterCore::Oai::Base
  
  base_url "http://library.org"

  attribute :identifier do
    get(:dc_identifier).find_without(/http/)
  end

  attribute :category,                default: "Research papers"

  attribute :title,                   from: "dc:title"
  attribute :dc_identifier,           from: "dc:identifier"

  attribute :enrichment_url do
    get(:dc_identifier).find_and_replace(/.*handle.net(.*)/ => 'https://researchspace.auckland.ac.nz/handle\1?show=full')
  end

  enrich_attribute :citation,                   xpath: "//table/tr", if: {"td[1]" => "dc.identifier.citation"}, value: "td[2]"
end