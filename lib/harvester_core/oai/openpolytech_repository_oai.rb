class OpenpolytechRepositoryOai < HarvesterCore::Oai::Base
         
  base_url "http://repository.openpolytechnic.ac.nz/oai/request"
  
  attribute  :archive_title,                             default: "openpolytech-repository-oai"
  attribute  :category,                                  default: "Research papers"
  attributes :display_collection, :primary_collection,   default: "Open Polytechnic Repository"
  attribute  :collection,                                default: ["Open Polytechnic Repository","Kiwi Research Information Service"]
  attributes :display_content_partner, :content_partner, default: "Open Polytechnic"

  attribute  :identifier,                  from: "identifier"
  attribute  :title,                       from: "dc:title"
  attribute  :contributor,                 from: "dc:contributor"
  attribute  :publisher,                   from: "dc:publisher"
  attribute  :creator,                     from: "dc:creator"
  attribute  :date,                        from: "dc:date", date: true
  attribute  :subject,                     from: ["dc:subject","keyword"]
  attribute  :relation,                    from: "dc:relation"
  attribute  :language,                    from: "dc:language"
  attribute  :description,                 from: "dc:description"

  # chaining? is it possible? and is order right?
  attributes :identifier, :landing_url, from: "dc:identifier" do
    find_with(/^http/).select(:first).within(:identifier)
  end  

  attribute :display_date, from: "dc:date", date: "%d %m %Y" do
    select(:first).within(:display_date)
  end  

  # is marsden_code correctly specified
  attribute :marsden_code, from: "dc:subject" do
    find_and_replace(/^(\d*)[^\d].*$/ => '\1').within(:marsden_code)    
  end

  # def set_rights
    # this is where we need to implement the rights mapping/lookup for the various rights fields based on the value in dc:rights
  # end

  # the next 2 fields (type and tag) use a large "mapType" and "validTag" transformer that is also called in 8 or so other KRIS configs...

  attribute :dc_type, from: "dc:type" do
    # the type field needs to be mapped according to the transformer in parser/conf/fragments/kris_transformers.frag 
  end

  attribute :tag do
    # this gathers its values from landing_url and dc_type
    # 1) if there is a tag that matches /^https?://hdl.handle.net.*$/ then that tag is mapped to "valid_handle" (leaving any other tags for the next step)
    # 2) if the type mapping has been successful then a tag is mapped to "valid_eprints"  (see parser/conf/fragments/kris_transformers.frag for more info)
    # 3) all leftover tags (not mapped by the previous 2 steps ie not matching /^valid_\w*$/) are erased/wiped/removed leaving only "valid_eprints" or "valid_handle".
  end

  # reject_if do
  #   get(:landing_url).find_without(/^https?:\/\//).present?
  # end
end
