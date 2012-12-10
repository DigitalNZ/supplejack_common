require "dnz_harvester/json/base"

Dir[File.dirname(__FILE__) + '/json/*.rb'].each {|file| require file }