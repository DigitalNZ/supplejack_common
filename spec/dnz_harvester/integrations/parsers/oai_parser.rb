class OaiParser < DnzHarvester::Oai::Base
  
  base_url "http://library.org"

  attribute :identifier do
    find_without(/http/).within(:dc_identifier)
  end

  attribute :category,                default: "Research papers"

  attribute :title,                   from: "dc:title"
  attribute :dc_identifier,           from: "dc:identifier"

  attribute :enrichment_url do
    find_and_replace(/.*handle.net(.*)/, 'https://researchspace.auckland.ac.nz/handle\1?show=full').within(:dc_identifier)
  end

  enrich_attribute :citation,                   xpath: "//table/tr", if: {"td[1]" => "dc.identifier.citation"}, value: "td[2]"
end