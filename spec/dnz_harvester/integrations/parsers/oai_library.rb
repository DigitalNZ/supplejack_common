class OaiLibrary < DnzHarvester::Oai::Base
  
  base_url "http://library.org"

  attribute :category,                default: "Research papers"

  attribute :title,                   from: "dc:title"
  attribute :dc_identifier,           from: "dc:identifier"

  enrich :citation,                   xpath: "table/tr", if: {"td[1]" => "dc.identifier.citation"}, value: "td[2]"

  def identifier
    find_without(/http/).within(:dc_identifier)
  end

  def enrichment_url
    find_and_replace(/.*handle.net(.*)/, 'https://researchspace.auckland.ac.nz/handle\1?show=full').within(:dc_identifier)
  end
end