require "harvester_core/oai/base"
require "harvester_core/oai/paginated_collection"
require "harvester_core/oai/client/record"

Dir[File.dirname(__FILE__) + '/oai/*.rb'].each {|file| require file }