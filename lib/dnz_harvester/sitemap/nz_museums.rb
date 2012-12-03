class NzMuseums < DnzHarvester::Sitemap::Base
  
  base_url "/Users/fede/code/dnz/config/harvester-resources/dnz03/sitemaps/nzmuseums-sitemap-reservebank.xml"

  attribute :archive_title,       default: "nzmuseums"
  attribute :collection,          default: ["NZMuseums"]
  attribute :source,              default: "NZMuseums"

  attributes :thumbnail_url, :large_thumbnail_url, xpath: ["div[@class='ehObjectSingleImage']/a/img", "div[@class='ehObjectImageMultiple']/a/img"], value: :src

  with_options xpath: "div[@class='ehFieldLabelDescription']", if: {"span[@class='label']" => :label_value}, value: "span[@class='value']" do |w|

    w.attribute :title,                 label_value: "Name/Title"
    w.attribute :creator,               label_value: "Maker"
    w.attribute :description,           label_value: ["About this object", "Subject and Association Description", "Inscription and Marks"]
    w.attributes :coverage, :placename, label_value: "Place Made"
    w.attribute :identifier,            label_value: "Object number"
    w.attribute :dc_type,               label_value: "Object Type"
    w.attribute :format,                label_value: "Medium and Materials"
    w.attribute :contributor,           label_value: "Collection"

  end

  attribute :subject,     xpath: "form[@class='ehTagForm']/span/a"
  attribute :license,     xpath: "div[@class='ehObjectLicence']/a", value: :href,
                          mappings: {
                            ".*Attribution$" => "CC-BY",
                            ".*Attribution_-_Share_Alike$" => "CC-BY-SA",
                            ".*Attribution_-_No_Derivatives$" => "CC-BY-ND",
                            ".*Attribution_-_Non-commercial$" => "CC-BY-NC",
                            ".*Attribution_-_Non-commercial_-_Share_Alike$" => "CC-BY-NC-SA",
                            ".*Attribution_-_Non-Commercial_-_No_Derivatives$" => "CC-BY-NC-ND"
                          }

  attributes :content_partner, :display_content_partner, :publisher, xpath: "div[@class='ehFieldAccountLink']/a"

  attribute :date,          xpath: "li[@span='Date Made']"
  attribute :display_date,  xpath: "div[@class='ehRepeatingLabelDescription']", if: {"span[@class='label']" => "Date Made"}, value: "span[@class='value']"

  def category
    return "Images" if original_attributes[:thumbnail_url].present?
    return "Other"
  end

  def thumbnail_url
    find_and_replace(/m\.jpg$/, "s.jpg").within(:thumbnail_url)
  end

  def large_thumbnail_url
    find_and_replace(/m\.jpg$/, "l.jpg").within(:thumbnail_url)
  end

  def usage
    content_partners = *original_attributes[:content_partner]
    return ["All rights reserved"] if content_partners & ["Shantytown", "Wanganui Collegiate School Museum", "Whanganui Regional Museum"]
      
    # TODO
    # Determine the mapping for the usage from the license information
    # Since this seems to be a common pattern we could create a method which we could
    # reuse across harvests.
    # 
    # Something like:
    #
    #   get_usage_from_cc_license(original_attributes[:license])
    #
  end
end