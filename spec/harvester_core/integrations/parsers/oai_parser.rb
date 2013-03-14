class OaiParser < HarvesterCore::Oai::Base
  
  base_url "http://library.org"

  attribute :identifier,              xpath: "//header/identifier" do
    get(:identifier).find_without(/http/)
  end

  attribute :category,                default: "Research papers"

  attribute :title,                   xpath: "//title"
  attribute :dc_identifier,           xpath: "//metadata/dc/identifier"

  attribute :enrichment_url do
    get(:dc_identifier).find_with(/http/).mapping(/.*handle.net(.*)/ => 'https://researchspace.auckland.ac.nz/handle\1?show=full')
  end
end