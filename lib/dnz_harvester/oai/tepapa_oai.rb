class TepapaOai < DnzHarvester::Oai::Base
  
  base_url "http://collections.tepapa.govt.nz/oai2.aspx"

  attribute :archive_title,                                  default: "tepapa-oai"
  attributes :content_partner, :display_content_partner,     default: "Museum of New Zealand Te Papa Tongarewa"
  # attribute :collection do
  #   ["Te Papa Collections Online", "Matapihi"] + fetch("//dc:relation").find_all_without([/http/, /DigitalNZ/])
  # end
  attributes :display_collection, :primary_collection,       default: "Te Papa Collections Online"
  attributes :copyright, :usage,                             default: "All rights reserved"

  attribute :title,         from: "dc:title"

  # attribute :subject,       from: "dc:subject" do
  #   subjects = get(:subject)
  #   relation_subjects = fetch("//dc:relation").find_all_without([/http/, /DigitalNZ/])
  #   title_subjects = get(:title).select(2, :last)
  #   subjects + relation_subjects + title_subjects
  # end

  attribute :description,   from: "dc:description" 
  attribute :date,          from: "dc:date",        date: true
  attribute :contributor,   from: "dc:contributor"
  attribute :publisher,     from: "dc:publisher"
  attribute :dc_type,       from: "dc:type" do
    find_and_replace(/([^\s])([A-Z])/, '\1 \2').within(:dc_type)
  end

  attributes :thumbnail_url,        from: "dc:relation" do
    find_all_with(/digitalnzthumb\.jpg/).within(:thumbnail_url)
  end

  attributes :large_thumbnail_url,  from: "dc:relation" do
    find_and_replace([/(width=\d*)/, 'width=640'], [/(height=\d*)/, 'height=640']).within(:large_thumbnail_url)
  end

  # attribute :dc_identifier,  from: "dc:identifier" do
  #   get(:dc_identifier).select(-2, :last)
  # end

  # attribute :category do
  #   if get(:dc_type) =~ /^video$/i
  #     "Videos"
  #   elsif get(:dc_identifier) == "narrative"
  #     "Reference sources"
  #   else
  #     "Images"
  #   end
  # end

  attribute :landing_url do
    find_with(/http/).within(:dc_identifier)
  end
  
end