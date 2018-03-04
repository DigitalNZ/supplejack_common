# frozen_string_literal: true

class XmlParser < SupplejackCommon::Xml::Base
  base_url 'http://digitalnz.org/xml'

  namespaces g: 'http://digitalnz.org/schemas/test',
             person: 'http://schema.org/Person',
             dc: 'http://digitalnz.org/schemas/dc'

  record_selector '/g:items/g:item'

  record_format :xml

  attribute :content_partner,         default: 'NZ On Screen'

  attribute :title,                   xpath: '/g:title'
  attribute :description,             xpath: '//g:description'
  attribute :date,                    xpath: '/dc:date'

  attribute :display_date do
    fetch('/dc:date')
  end

  attribute :author, xpath: '/person:author/person:name'
end
