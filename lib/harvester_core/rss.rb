require "harvester_core/rss/base"

Dir[File.dirname(__FILE__) + '/rss/*.rb'].each {|file| require file }