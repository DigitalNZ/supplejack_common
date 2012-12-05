require 'active_support/all'
require 'feedzirra'
require 'oai'
require 'rest_client'

require "dnz_harvester/version"
require "dnz_harvester/utils"
require "dnz_harvester/scope"

require "dnz_harvester/filters/selectors"
require "dnz_harvester/filters/transformers"
require "dnz_harvester/filters/conditions"
require "dnz_harvester/filters/finders"
require "dnz_harvester/filters/modifiers"

require "dnz_harvester/base"

require "dnz_harvester/oai/base"
require "dnz_harvester/oai/auckland_uni_library"

require "dnz_harvester/rss/base"
require "dnz_harvester/rss/tv3"

require "dnz_harvester/sitemap/base"
require "dnz_harvester/sitemap/nz_museums"

require "dnz_harvester/xml/base"
require "dnz_harvester/xml/nz_on_screen"

module DnzHarvester
  # Your code goes here...
end