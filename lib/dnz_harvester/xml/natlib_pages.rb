class NatlibPages < DnzHarvester::Xml::Base
  
  base_url "file://Users/fede/code/dnz/config/harvester-resources/dnz03/sitemaps/nzmuseums-sitemap-reservebank.xml"
  basic_auth "preview", "IVa1ziet"
  record_url_selector "//loc"

  attribute  :archive_title,       									                  default: "sfr-pages"
  attribute  :category,            									                  default: "Guides & factsheets"
  attributes :content_partner, :display_content_partner,     		      default: "National Library of New Zealand"
  attributes :collection, :display_collection, :primary_collection,   default: "National Library Website"
  attributes :is_catalog_record, :is_natlib_record,					          default: true
  attributes :usage, :copyright,									                    default: "All rights reserved"

  attributes :landing_url, :identifier, 	xpath: "//dnz_id"
  attribute  :subject,                    xpath: "//meta[@name='keywords']/@content", separator: ","
  
  # attribute :title do
  #   if fetch("//head//title") != /^Collections\s*\|\s*Nat/
  #     fetch("//head//title")
  #   elsif fetch("//div[@class='content']//h2").present?
  #     fetch("//div[@class='content']//h2")
  #   else
  #     fetch("//div[@id='content']//h1")
  #   end
  # end
	
  attribute :description do
    values = []
    if fetch("//meta[@name='description']/@content").present?
      values << fetch("//meta[@name='description']/@content")
    else
      values << fetch("//div[@id='content']//p[1]")
    end

    values << fetch("//div[@class='event-info']/following-sibling::p")
    values.join("\n")
  end

  # reject_if do
  #   get(:landing_url).find_all_with([/search-stations/,
  #         /natlib.govt.nz\/$/,
  #         /digitalnz.org\/$/,
  #         /page-not-found$/,
  #         /\/about$/,
  #         /\/help$/,
  #         /sorry-this-image-cant-be-copied$/,
  #         /sorry-this-item-cant-be-borrowed$/,
  #         /sorry-this-item-cant-be-copied$/,
  #         /page-under-services$/,
  #         /footer$/,
  #         /log-on-to-the-national-library$/,
  #         /manage-igovt$/
  #       ]).present?
  # end
  
end