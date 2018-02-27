# frozen_string_literal: true

require 'supplejack_common/oai/base'
require 'supplejack_common/oai/paginated_collection'
require 'supplejack_common/oai/client/record'

Dir[File.dirname(__FILE__) + '/oai/*.rb'].each { |file| require file }
