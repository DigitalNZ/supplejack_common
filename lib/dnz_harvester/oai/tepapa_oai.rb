class TepapaOai < DnzHarvester::Oai::Base
       
  # Need to confirm:
  # - why is identifier and landing_url not standard xpath (and are they right)
  # - if i define one static collection up top, can I add another collection value to the array further down from an xpath query
  
  base_url "http://collections.tepapa.govt.nz/oai2.aspx"

  attribute :archive_title,                                  default: "tepapa-oai"
  attributes :content_partner, :display_content_partner,     default: "Museum of New Zealand Te Papa Tongarewa"
  attribute :collection,                                     default: ["Te Papa Collections Online", "Matapihi"]
  attributes :display_collection, :primary_collection,       default: "Te Papa Collections Online"
  attributes :copyright, :usage,                             default: "All rights reserved"

  attribute :title,         from: "dc:title"
  attribute :subject,       from: "dc:subject"
  attribute :description,   from: "dc:description" 
  attribute :date,          from: "dc:date"
  attribute :contributor,   from: "dc:contributor"
  attribute :publisher,     from: "dc:publisher"  
  attribute :dc_type,       from: "dc:type"
  
  # This line certainly needs some work
  # based of -- attribute :display_date,  xpath: "//div[@class='ehRepeatingLabelDescription']", if: {"span[@class='label']" => "Date Made"}, value: "span[@class='value']"
  attributes :collection, :subject,                  from: "dc:relation" do
    find_all_without([/http/, /DigitalNZ/]).within(:subject)
  end

  attributes :thumbnail_url, :large_thumbnail_url,   from: "dc:relation" do
    find_all_with(/digitalnzthumb\.jpg/).within(:thumbnail_url)
  end
  
  # can I specify a position
  attribute :subject,        from: "dc:title" do
    original_attributes[:subject][1..-1]
  end

  attribute :dc_identifier,  from: "dc:identifier" do
    original_attributes[:dc_identifier][-2..-1]
  end
  
  # hows this looking (is the ? meant to be there)
  # can I specify a regex there?
  def category
    return "Videos" if original_attributes[:dc_type] =~ /^video$/i
    return "Reference sources" if original_attributes[:dc_identifier] == "narrative"
    return "Images"
  end

  def landing_url
    find_with(/http/).within(:dc_identifier)
  end

  # is that how you specify the remembered $1 $2
  def dc_type
    find_and_replace(/([^\s])([A-Z])/, '\1 \2').within(:dc_type)
  end
    
  # do I have to setup large thumb up top or just make it here by pulling it from thumbnail_url?  
  def large_thumbnail_url
    value = find_and_replace(/(width=\d*)/, 'width=640').within(:large_thumbnail_url)
    find_and_replace(/(height=\d*)/, 'height=640').within(value)
  end
  
  
end