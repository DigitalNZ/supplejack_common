require "harvester_core/xml/base"

Dir[File.dirname(__FILE__) + '/xml/*.rb'].each {|file| require file }