class OaiParser < HarvesterCore::Oai::Base
  
  base_url "http://library.org"

  namespaces dc: 'http://purl.org/dc/elements/1.1/'

  attribute :identifier,              xpath: "//header/identifier" do
    get(:identifier).find_without(/http/)
  end

  attribute :category,                default: "Research papers"

  attribute :title,                   xpath: "//dc:title"
  attribute :dc_identifier,           xpath: "//dc:identifier"

  attribute :enrichment_url do
    get(:dc_identifier).find_with(/http/).mapping(/.*handle.net(.*)/ => 'https://researchspace.auckland.ac.nz/handle\1?show=full')
  end
end