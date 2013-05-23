require "harvester_core/sitemap/base"

Dir[File.dirname(__FILE__) + '/sitemap/*.rb'].each {|file| require file }