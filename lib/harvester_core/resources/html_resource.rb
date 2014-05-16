# The Supplejack code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack_core 

module HarvesterCore
  class HtmlResource < XmlResource
    
    def document
      @document ||= Nokogiri::HTML.parse(fetch_document)
    end
  end
end