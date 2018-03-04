# frozen_string_literal: true

require 'supplejack_common/rss/base'

Dir[File.dirname(__FILE__) + '/rss/*.rb'].each { |file| require file }
