# frozen_string_literal: true

require 'supplejack_common/sitemap/base'

Dir[File.dirname(__FILE__) + '/sitemap/*.rb'].each { |file| require file }
