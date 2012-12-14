class SitemapParser < DnzHarvester::Sitemap::Base
  
  base_url "/path/to/file/sitemap.xml"

  attribute :collection,          default: "NZMuseums"

  attribute :thumbnail_url, xpath: ["//div[@class='ehObjectSingleImage']/a/img/@src", "//div[@class='ehObjectImageMultiple']/a/img/@src"] do
    get(:thumbnail_url).find_and_replace(/m\.jpg$/ => "s.jpg")
  end

  with_options xpath: "//div[@class='ehFieldLabelDescription']", if: {"span[@class='label']" => :label_value}, value: "span[@class='value']" do |w|

    w.attribute :title,                 label_value: "Name/Title"
    w.attribute :description,           label_value: ["About this object", "Subject and Association Description", "Inscription and Marks"]
    w.attributes :coverage, :placename, label_value: "Place Made"
    w.attribute :identifier,            label_value: "Object number"

  end

  attribute :tags,        xpath: "//a[@class='ehTagReadOnly']"
  attribute :license,     xpath: "//div[@class='ehObjectLicence']/a/@href",
                          mappings: {
                            /.*Attribution$/ => 'CC-BY',
                            /.*Attribution_-_Share_Alike$/ => 'CC-BY-SA',
                            /.*Attribution_-_No_Derivatives$/ => 'CC-BY-ND',
                            /.*Attribution_-_Non-commercial$/ => 'CC-BY-NC',
                            /.*Attribution_-_Non-commercial_-_Share_Alike$/ => 'CC-BY-NC-SA',
                            /.*Attribution_-_Non-Commercial_-_No_Derivatives$/ => 'CC-BY-NC-ND'
                          }


  attribute :display_date,  xpath: "//div[@class='ehRepeatingLabelDescription']", 
                            if: {"span[@class='label']" => "Date Made"}, 
                            value: "span[@class='value']",
                            date: true

  attribute :category do
    get(:thumbnail_url).present? ? "Images" : "Other"
  end

end