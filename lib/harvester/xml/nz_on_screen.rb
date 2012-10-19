class NzOnScreen < Harvester::Xml::Base
  
  base_url "http://zachobson:f1ash1ight@www.nzonscreen.com/api/title/"

  attribute :content_partner,         default: ["NZ On Screen"]
  attribute :display_content_partner, default: "NZ On Screen"

  attribute :collection,              default: ["NZ On Screen"]
  attribute :display_collection,      default: "NZ On Screen"

  attribute :category,                default: ["Videos"]
  attribute :title,                   xpath: "name"
  attribute :description,             xpath: "synopsis"
  attribute :date,                    xpath: "dc:date"
  attribute :contributor,             xpath: "person", object: true
  attribute :subject,                 xpath: "dc:subject"
  attribute :dnz_type,                xpath: "media-category"
  attribute :language
  attribute :tag,                     xpath: "tags", separator: ","
  attribute :thumbnail_url,           xpath: "thumbnail-image/title/path"
  attribute :large_thumbnail_url,     xpath: "thumbnail-image/large/path"
  attribute :dc_type,                 xpath: "genre", separator: ","

  def contributor
    return nil unless original_attributes[:contributor].respond_to?(:each)
    original_attributes[:contributor].map do |person|
      first_name = person.xpath("first-name")
      last_name = person.xpath("last-name")
      [first_name, last_name].join(" ")
    end
  end
end