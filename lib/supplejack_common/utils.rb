# The Supplejack Common code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack 

require 'benchmark'

module SupplejackCommon
  module Utils
    extend self

    #
    # Return a array no matter what.
    #
    def array(object)
      case object
      when Array
        object
      when String
        object.present? ? [object] : []
      when NilClass
        []
      else
        [object]
      end
    end

    def add_html_tag(html)
      unless html.match(/(<(!DOCTYPE )?html.*>)|(<\?xml.*\?>)/i)
        html = "<html>#{html}</html>"
      end
      html
    end

    def add_namespaces(xml, namespaces={})
      namespaces_string = namespaces.map {|k,v| "#{k}='#{v}'" }.join(" ")
      "<root #{namespaces_string}>#{xml}</root>"
    end
  end
end