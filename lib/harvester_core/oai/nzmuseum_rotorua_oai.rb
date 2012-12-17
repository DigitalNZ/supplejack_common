class NzmuseumsRotoruaOai < HarvesterCore::Oai::Base
         
  base_url "http://ehive.com/oai-pmh/accounts/3064"

  attributes :content_partner, :display_content_partner,     default: "Rotorua Museum of Art & History Te Whare Taonga o Te Arawa"
  
  # above this line is unique to rotorua museums
  # everything below is repeated for all 16 nzmuseums configs
  
  attribute  :archive_title,           					     		             default: "nzmuseums"
  attributes :display_collection, :primary_collection, :collection,	 default: "NZMuseums"
  attribute  :category,           					     			               default: "Images"

  attribute :date,          			from: "dc:date", date: true
  attribute :display_date,        from: "dc:date", date: "%d/%m/%Y"
  attribute :format,         			from: "dc:format"
  attribute :title,         			from: "dc:title"
  attribute :coverage,       			from: "dc:coverage"
  attribute :publisher,       		from: "dc:publisher"
  attribute :contributor,       	from: "dc:contributor"
  attribute :subject,       			from: "dc:subject"
  attribute :creator,     				from: "dc:creator"  
  attribute :dc_type,       			from: "dc:type"
  attribute :description,   			from: "dc:description"
  attribute :language,   				  from: "dc:language" 

  # attribute :thumbnail_url do
  #   fetch("//dc:identifier[@linktype='thumbnail']")
  # end
  
  # attributes :landing_url, :identifier do
  #   fetch("//dc:identifier[@linktype='fulltext']").find_and_replace(/http:\/\/ehive.com/ => 'http://www.nzmuseums.co.nz')
  # end
  
  # def large_thumbnail_url
  #   get(:thumbnail_url).find_and_replace(/_m.(\w\w\w+)$/ => '_l.\1')
  # end
  
  # def set_rights
    # this is where we need to implement the rights mapping/lookup for the various rights fields based on the value in dc:rights
  # end
  
end
