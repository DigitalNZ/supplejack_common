require_relative 'base'

class Tv3
  include Harvester::Rss::Base
  
  base_url "http://www.3news.co.nz/DesktopModules/Article%20Presentation/External.aspx?tabid=783&moduleid=5943&cat=64"
  base_url "http://www.3news.co.nz/DesktopModules/Article%20Presentation/External.aspx?tabid=783&moduleid=5943&cat=67"

  default :archive_title,           "tv3-rss"
  default :category,                ["Newspapers"]
  default :content_partner,         ["TV3"]
  default :display_content_partner, "TV3"
  default :creator,                 ["TV3"]
  default :collection,              "tv3.co.nz"
  default :copyright,               ["All rights reserved"]

  attribute :title
  attribute :description, from: :summary

  attributes :date, :display_date, from: :published
  attributes :identifier, :dc_identifier, :landing_url, from: :url

  attribute :thumbnail_url, from: :enclosure, value: :url, with: {type: "image/jpeg"}

  def large_thumbnail_url
    find_and_replace(/width=[\d]{1,4}/, "width=520").within(:thumbnail_url)
  end

  def category
    add("Images", to: :category).if_present(:thumbnail_url)
  end
end