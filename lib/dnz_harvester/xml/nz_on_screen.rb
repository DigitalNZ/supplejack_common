class NzOnScreen < DnzHarvester::Xml::Base
  
  base_url "http://www.nzonscreen.com/api/title/"
  basic_auth "zachobson", "f1ash1ight"
  record_url_selector "//loc"

  attribute :content_partner,         default: ["NZ On Screen"]
  attribute :display_content_partner, default: "NZ On Screen"

  attribute :collection,              default: ["NZ On Screen"]
  attribute :display_collection,      default: "NZ On Screen"

  attribute :category,                default: ["Videos"]
  attribute :title,                   xpath: "//name"
  attribute :description,             xpath: "//synopsis"
  attribute :date,                    xpath: "//dc:date"
  attribute :contributor,             xpath: "//person", object: true
  attribute :subject,                 xpath: "//dc:subject"
  attribute :dnz_type,                xpath: "//media-category"
  attribute :language
  attribute :tag,                     xpath: "//tags", separator: ","
  attribute :thumbnail_url,           xpath: "//thumbnail-image/title/path"
  attribute :large_thumbnail_url,     xpath: "//thumbnail-image/large/path"
  attribute :dc_type,                 xpath: "//genre", separator: ","
  attribute :attachments,             xpath: "//video", object: true

  def contributor
    return nil unless original_attributes[:contributor].respond_to?(:each)
    original_attributes[:contributor].map do |person|
      first_name = person.xpath("first-name")
      last_name = person.xpath("last-name")
      [first_name, last_name].join(" ")
    end
  end

  def attachments
    original_attributes[:attachments].map do |video|
      attributes = {}
      attributes[:name] = video.xpath("label").text
      attributes[:url] = video.xpath("files/hi_res/m4v").text
      attributes[:aspect_ratio] = video.xpath("aspect_ratio").text
      attributes[:dc_type] = "Videos"
      attributes[:large_thumbnail_url] = self.large_thumbnail_url
      attributes[:dc_identifier] = attributes[:url].split("/").last
      attributes
    end
  end
end