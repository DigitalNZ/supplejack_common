class BfmRss < DnzHarvester::Rss::Base
  
  base_url "http://www.95bfm.co.nz/sm/podcasts.rss"

  attribute  :archive_title,            default: "bfm-rss"
  attribute  :category,                 default: "Audio"
  attribute  :language,                 default: "en"
  attributes :content_partner, :display_content_partner, :display_collection, :primary_collection, default: "95bFM"

  attributes :identifier, :landing_url, from: :url
  attribute  :title,                    from: :title
  attribute  :description,              from: :description, truncate: "default"
  attribute  :date,                     from: :published, date: true
  attribute  :display_date,             from: :published, date: "%d %m %Y"
  attribute  :creator,                  xpath: "//itunes:author"
  attribute  :object_url,               xpath: "//enclosure/@url"
  attribute  :dc_type,                  xpath: "//enclosure/@type"

  # collection is a multivalue field with the radio show name and 95bFM
  # def collection
  #   radioshow = get(:title).find_and_replace(/:.*$/ => '')
  #   radioshow + "95bFM"
  # end

  # TODO
  #   hardcode all rights fields to all rights reserved
  #   attributes :usage, :copyright, default: "All rights reserved"
  # end

  # def attachments
  #   [{
  #     url: get(:object_url),
  #     name: get(:title),
  #     type: get(:dc_type),
  #   }]
  # end

end