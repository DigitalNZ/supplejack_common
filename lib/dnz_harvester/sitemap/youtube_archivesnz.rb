class YoutubeArchivesnz < DnzHarvester::Sitemap::Base
  
  # base_url "file:///data/apps/harvester/resource_deployments/current/sitemaps/youtube-archivesnz-sitemap.xml"
  base_url "http://gdata.youtube.com/feeds/api/videos?author=archivesnz&orderby=published"
  # paginate page_parameter: "start-index", type: "item", per_page_parameter: "max-results", per_page: 50, start: 1
  # record_selector "//entry"

  attribute  :archive_title,       									                 default: "youtube-archivesnz"
  attribute  :category,            									                 default: "Videos"
  attributes :content_partner, :display_content_partner,     		     default: "Archives New Zealand Te Rua Mahara o te Kawanatanga"
  attributes :collection, :display_collection, :primary_collection,  default: "YouTube"
  attributes :is_catalog_record, :is_natlib_record,					         default: "true"
  attributes :usage, :copyright,									                   default: "All rights reserved"

  attribute  :title,                     	  xpath: "//media:title"
  attribute  :description,                  xpath: "//media:description"
  attribute  :creator,                  	  xpath: "//category/author/name"
  attributes :landing_url, :identifier, 	  xpath: "//media:player/@url"
  attribute  :thumbnail_url,                xpath: "//media:thumbnail"
    
end