class QuakeStoriesPhotos < DnzHarvester::Rss::Base
  
  base_url "http://www.quakestories.govt.nz/photos/feed"

  attribute :archive_title,           default: "quake-stories-photos"
  attribute :category,                default: "Images"
  attribute :content_partner,         default: "Ministry for Culture and Heritage"
  attribute :display_content_partner, default: "Ministry for Culture and Heritage"
  attribute :collection,              default: ["CEISMIC", "QuakeStories"]
  attributes :display_collection, :primary_collection, default: "QuakeStories"
  attribute :rights_url,              default: "http://creativecommons.org/licenses/by-nc-sa/3.0/nz/deed.en"
  attribute :rights,                  default: "Content licensed under Creative Commons Attribution-NonCommercial-ShareAlike 3.0 license - 2011."
  attribute :license,                 default: "CC-BY-NC-SA"
  attribute :usage,                   default: ["Share", "Modify"]
  attribute :copyright,               default: "Some rights reserved"
  
  attribute :title,                     from: :title
  attribute :description,               from: :description, truncate: "default"
  attribute :creator,                   from: :author
  attributes :date, :display_date,      from: :published
  attributes :identifier, :landing_url, from: :url
  attributes :thumbnail_url, :large_thumbnail_url, from: :enclosure

  def thumbnail_url
    get(:thumbnail_url).find_and_replace(/^.*\/stories\/(.*)\.\w\w\w\w?$/ => 'http://www.quakestories.govt.nz/thumbnail.ashx?image=/images/stories/\1.jpg&width=150&constrain=true')
  end
  
  def large_thumbnail_url
    get(:thumbnail_url).find_and_replace(/^.*\/stories\/(.*)\.\w\w\w\w?$/ => 'http://www.quakestories.govt.nz/thumbnail.ashx?image=/images/stories/\1.jpg&width=520&constrain=true')
  end
  
  # def attachments
  #   [{
  #     name: get(:title),
  #     url: get(:thumbnail_url),
  #     dc_type: "Images",
  #     thumbnail_url: get(:thumbnail_url),
  #     large_thumbnail_url: get(:large_thumbnail_url)
  #   }]
  # end
end