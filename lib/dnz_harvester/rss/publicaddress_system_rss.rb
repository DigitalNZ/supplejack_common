class PublicaddressSystemRss < DnzHarvester::Rss::Base
  
  base_url "http://publicaddress.net/all.rss"

  attribute  :archive_title,            default: "publicaddress-system-rss"
  attribute  :category,                 default: "Newspapers"
  attribute  :language,                 default: "en"
  attributes :content_partner, :display_content_partner, :display_collection, :primary_collection, default: "Public Address"

  attributes :identifier, :landing_url, from: :url
  attribute  :date,                     from: :published, date: true
  attribute  :display_date,             from: :published, date: "%d %m %Y"
  attribute  :creator,                  xpath: "//dc:creator"


  # this description uses the trimCDATA transformer and also needs a html tag remover
  # note: the htmltag remover should remove a "<br>" with no spaces around it, and replace it with " "
  attribute :description,  from: "description" do
    get(:description).find_and_replace(/^\s*&lt;.\[CDATA\[(.*)\]\]&gt;\s*$/ => '')
  end 

  attribute :title, from: :title do
    get(:title).find_and_replace(/^.*?:\s*/ => '')
  end  

  attribute :thumbnail_url do
    get(:identifier).find_and_replace(/^.*publicaddress\.net\/([^\/]*)\/.*$/ => '\1', /[^a-zA-Z]/ => '', /^(.*)$/ => 'http://assets.digitalnz.org/thumbs/pa/\1.jpg')
  end  

  # collection is a multivalue field ie ["radio show name", "Public Address"]
  # def collection
  #   radioshow = fetch(//title).find_and_replace(/^(.*?):.*$/ => '\1')
  #   radioshow + "Public Address"
  # end

  # TODO
  #   hardcode all rights fields to all rights reserved
  #   attributes :usage, :copyright, default: "All rights reserved"
  # end

end