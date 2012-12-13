class NatlibPages < DnzHarvester::Sitemap::Base
  
  base_url "/Users/fede/code/dnz/config/harvester-resources/dnz03/sitemaps/nzmuseums-sitemap-reservebank.xml"
  basic_auth "preview", "IVa1ziet"

  attribute  :archive_title,       									default: "sfr-pages"
  attribute  :category,            									default: "Guides & factsheets"
  attributes :content_partner, :display_content_partner,     		default: "National Library of New Zealand"
  attributes :collection, :display_collection, :primary_collection, default: "National Library Website"
  attributes :is_catalog_record, :is_natlib_record,					default: "true"
  attributes :usage, :copyright,									default: "All rights reserved"

  attributes :landing_url, :identifier, 	xpath: "//dnz_id"
  attribute  :subject,                     	xpath: "//meta[@name='keywords']/@content", separator: ","
  
  # def title
    # Should return one of these. Previously used the onExisting=ignore functionality
    # return xpath: "//head//title" if xpath: "//head//title" != /^Collections\s*\|\s*Nat/
    # return xpath: "//div[@class="content"]//h2"
    # return xpath: "//div[@id="content"]//h1"
  # end
	
  # def description
    # not sure how to specify this at all, but I want
	# xpath: "//meta[@name='description']/@content" if it exists, else xpath: "//div[@id='content']//p[1]" 
	# and then to append xpath: "//div[@class='event-info']/following-sibling::p" with a separator="&#10"
  # end
     
  # something to enable rejecting records based on a list of criteria
  def reject_record
    reject_record if find([/search-stations/, /natlib.govt.nz\/$/, /digitalnz.org\/$/, /page-not-found$/, /\/about$/, /\/help$/, /sorry-this-image-cant-be-copied$/, /sorry-this-item-cant-be-borrowed$/, /sorry-this-item-cant-be-copied$/, /page-under-services$/, /footer$/, /log-on-to-the-national-library$/, /manage-igovt$/]).within(:landing_url)
  end
  
end