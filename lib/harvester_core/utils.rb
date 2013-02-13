require 'benchmark'

module HarvesterCore
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

    def remove_default_namespace(xml)
      xml.gsub(/ xmlns=(?:"|')[A-Za-z0-9:\/\.\-]+(?:"|')/, "")
    end

    def add_html_tag(html)
      unless html.match(/(<(!DOCTYPE )?html.*>)|(<\?xml.*\?>)/i)
        html = "<html>#{html}</html>"
      end
      html
    end
  end
end