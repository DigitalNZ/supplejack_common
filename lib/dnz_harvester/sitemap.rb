require "dnz_harvester/sitemap/base"

Dir[File.dirname(__FILE__) + '/sitemap/*.rb'].each {|file| require file }