class PublicaddressRadioRss < DnzHarvester::Rss::Base
  
  base_url "http://publicaddress.net/all.rss"

  attribute  :archive_title,            default: "publicaddress-radio-rss"
  attribute  :category,                 default: "Audio"
  attribute  :collection,               default: ["Public Address Radio", "Public Address"]
  attributes :content_partner, :display_content_partner, :display_collection, :primary_collection, default: "Public Address"

  attributes :identifier, :landing_url, from: :url
  attribute  :date,                     from: :published, date: true
  attribute  :title,                    from: :title
  attribute  :display_date,             from: :published, date: "%d %m %Y"
  attribute  :object_url,               xpath: "//enclosure/@url"


  # this description uses the trimCDATA transformer and also needs a html tag remover
  # note: the htmltag remover should remove a "<br>" with no spaces around it, and replace it with " "
  attribute :description,  from: "description" do
    get(:description).find_and_replace(/^\s*&lt;.\[CDATA\[(.*)\]\]&gt;\s*$/ => '')
  end 

  # def attachments
  #   [{
  #     url:  get(:object_url),
  #     name: get(:title),
  #     type: fetch("//enclosure/@type"),
  #   }]
  # end

  # TODO
  #   hardcode all rights fields to all rights reserved
  #   attributes :usage, :copyright, default: "All rights reserved"
  # end

end