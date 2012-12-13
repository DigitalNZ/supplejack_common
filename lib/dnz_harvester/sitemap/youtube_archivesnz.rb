class YoutubeArchivesnz < DnzHarvester::Sitemap::Base
  
  base_url "file:///data/apps/harvester/resource_deployments/current/sitemaps/youtube-archivesnz-sitemap.xml"
  
  # need to specify how to identify individual records ofrom the youtube API (eg //feed/category/entry)
  # sitemap contains URL's like: http://gdata.youtube.com/feeds/api/videos?author=archivesnz&start-index=51&max-results=50&orderby=published
  # thats one of those pages that looks different in the XML source than hows its presented in my browser.  

  attribute  :archive_title,       									default: "youtube-archivesnz"
  attribute  :category,            									default: "Videos"
  attributes :content_partner, :display_content_partner,     		default: "Archives New Zealand Te Rua Mahara o te Kawanatanga"
  attributes :collection, :display_collection, :primary_collection, default: "YouTube"
  attributes :is_catalog_record, :is_natlib_record,					default: "true"
  attributes :usage, :copyright,									default: "All rights reserved"

  attribute  :title,                     	xpath: "//media:title"
  attribute  :description,                  xpath: "//media:description"
  attribute  :creator,                  	xpath: "//category/author/name"
  attributes :landing_url, :identifier, 	xpath: "//media:player/@url"
  attribute  :thumbnail_url,                xpath: "//media:thumbnail"
  
  # This could be worth turning into a either its own special type of harvester or building and using some kind of generic API harvester that can page thru API results rather than how this one uses a sitemap of manually created API paged calls
  
end