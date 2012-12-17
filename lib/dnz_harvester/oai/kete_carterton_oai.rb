class KeteCartertonOai < DnzHarvester::Oai::Base
         
  base_url "http://ketewls.peoplesnetworknz.info/oai_pmh_repository"
  
  attribute  :archive_title,                                        default: "kete-carterton"
  attributes :display_collection, :primary_collection, :collection, default: "Carterton Kete"
  attributes :display_content_partner, :content_partner,            default: "Carterton District Library"

  # above this line is unique to the Carterton Kete
  # everything below is repeated for all other Kete's configs

  attribute  :date,                        from: "dc:date", date: true
  attribute  :display_date,                from: "dc:date", date: "%d %m %Y"
  attribute  :format,                      from: "dc:format"
  attribute  :identifier,                  from: "identifier"
  attributes :landing_url, :dc_identifier, from: "dc:identifier"
  attribute  :title,                       from: "dc:title"
  attribute  :publisher,                   from: "dc:publisher"
  attribute  :language,                    from: "dc:language"
  attribute  :subject,                     from: "dc:subject"
  attribute  :dc_type,                     from: "dc:type"

  # not sure about this chaining of find_with and find_and_replace
  attribute :thumbnail_url, from: "dc:source" do
    get(:thumbnail_url).find_with(/image_files/).find_and_replace(/^(.*)(\.\w+)$/ => '\1_medium\2', /tiff?\s*$/ => 'jpg')
  end    

  # not sure about this chaining of find_with and find_and_replace
  attribute :large_thumbnail_url,  from: "dc:source" do
    get(:large_thumbnail_url).find_with(/image_files/).find_and_replace(/^(.*)(\.\w+)$/ => '\1_large\2', /tiff?\s*$/ => 'jpg')
  end  

  attribute :object_url, from: "dc:source" do
    get(:object_url).find_with(/^http/)
  end   
  # above and below seem to use different syntax, not sure which is correct? (the get or the within)
  attribute :contributor, from: "dc:contributor" do
    find_without(/^[A-Z\s]*$/).within(:contributor)
  end

  attribute :creator, from: "dc:creator" do
    find_without(/^[A-Z\s]*$/).within(:creator)
  end

  # this is a trim_CDATA transformer that is used in a few other configs too...
  # 1)this needs to append each dc:description with a ". " separator.
  # 2)after the appending I need to do a find_and_replace to remove double dots (".. ")
  # 3) then the truncate
  attribute :description,  from: "dc:description" do
    get(:description).find_and_replace(/^\s*&lt;.\[CDATA\[(.*)\]\]&gt;\s*$/ => '')
  end  

  attribute :category do
    # case get(:dc_format)
    # when "image" then "Images"
    # when "video" then "Videos"
    # when "audio" then "Audio"
    # else
    #   "Community content"
    # end
  end
  
  # def set_rights
    # this is where we need to implement the rights mapping/lookup for the various rights fields based on the value in dc:rights
  # end

  # reject_if do
  #   get(:landing_url).find_all_with([/search-stations/,
  #         /\/help\//,
  #         /\/documentation\//,
  #         /\/web_links\//,
  #         /\/\d*.welcome$/,
  #         /#comment/,
  #         /bootstrap$/,
  #         /\/sandbox\//,
  #         /-theme$/
  #       ]).present?
  # end
end
