class XmlParser < DnzHarvester::Xml::Base
  
  base_url "http://www.nzonscreen.com/api/title/"
  record_url_selector "//loc"

  attribute :content_partner,         default: "NZ On Screen"
  attribute :category,                default: "Videos"

  attribute :title,                   xpath: "title/name"
  attribute :description,             xpath: "//synopsis"
  attribute :date,                    xpath: "//dc:date"

  attribute :tag,                     xpath: "//tags", separator: ","
  attribute :thumbnail_url,           xpath: "//thumbnail-image/title/path"

  attribute :contributor,             xpath: "//person", object: true do
    if original_attributes[:contributor].respond_to?(:each)
      original_attributes[:contributor].map do |person|
        first_name = person.xpath("first-name")
        last_name = person.xpath("last-name")
        [first_name, last_name].join(" ")
      end
    else
      nil
    end
  end
end