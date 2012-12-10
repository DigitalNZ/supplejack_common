require "dnz_harvester/rss/base"

Dir[File.dirname(__FILE__) + '/rss/*.rb'].each {|file| require file }