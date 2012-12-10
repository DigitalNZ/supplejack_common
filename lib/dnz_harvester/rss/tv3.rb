class Tv3 < DnzHarvester::Rss::Base
  
  base_url "http://www.3news.co.nz/DesktopModules/Article%20Presentation/External.aspx?tabid=783&moduleid=5943&cat=64"
  base_url "http://www.3news.co.nz/DesktopModules/Article%20Presentation/External.aspx?tabid=783&moduleid=5943&cat=67"

  attribute :archive_title,           default: "tv3-rss"
  attribute :category,                default: ["Newspapers"]
  attribute :content_partner,         default: ["TV3"]
  attribute :display_content_partner, default: "TV3"
  attribute :creator,                 default: ["TV3"]
  attribute :collection,              default: "tv3.co.nz"
  attribute :copyright,               default: ["All rights reserved"]

  attribute :title, from: :title
  attribute :description, from: :summary

  attributes :date, :display_date, from: :published
  attributes :identifier, :dc_identifier, :landing_url, from: :url

  attribute :thumbnail_url, from: :enclosure, value: :url, with: {type: "image/jpeg"}

  attribute :large_thumbnail_url do
    find_and_replace(/width=[\d]{1,4}/, "width=520").within(:thumbnail_url)
  end

  # def large_thumbnail_url
  #   find_and_replace(/width=[\d]{1,4}/, "width=520").within(:thumbnail_url)
  # end

  def category
    add("Images", to: :category).if_present(:thumbnail_url)
  end
end