require "dnz_harvester/xml/base"

Dir[File.dirname(__FILE__) + '/xml/*.rb'].each {|file| require file }