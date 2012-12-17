class RssParser < HarvesterCore::Rss::Base
  
  base_url "http://www.library.org/records"

  attribute :title,                   from: :title
  attribute :description,             from: :summary
  attribute :date,                    from: :published
  attribute :landing_url,             from: :url

  attribute :thumbnail_url, from: :enclosure, value: :url, with: {type: "image/jpeg"}

  attribute :category,                default: ["Newspapers"] do
    get(:category).add("Images") if get(:thumbnail_url).present?
  end

  attribute :large_thumbnail_url do
    get(:thumbnail_url).find_and_replace(/width=[\d]{1,4}/ => "width=520")
  end
end