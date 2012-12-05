class RssParser < DnzHarvester::Rss::Base
  
  base_url "http://www.library.org/records"

  attribute :category,                default: ["Newspapers"]

  attribute :title,                   from: :title
  attribute :description,             from: :summary
  attribute :date,                    from: :published
  attribute :landing_url,             from: :url

  attribute :thumbnail_url, from: :enclosure, value: :url, with: {type: "image/jpeg"}

  def large_thumbnail_url
    find_and_replace(/width=[\d]{1,4}/, "width=520").within(:thumbnail_url)
  end

  def category
    add("Images", to: :category).if_present(:thumbnail_url)
  end
end