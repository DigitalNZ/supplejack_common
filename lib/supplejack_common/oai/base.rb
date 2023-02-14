# frozen_string_literal: true

module SupplejackCommon
  module Oai
    class Base < SupplejackCommon::Base
      include SupplejackCommon::XmlDslMethods
      include SupplejackCommon::XmlDataMethods

      clear_definitions

      VALID_RECORDS_OPTIONS = %i[from limit].freeze

      attr_reader :original_xml

      class_attribute :_metadata_prefix
      self._metadata_prefix = {}

      class_attribute :_set
      self._set = {}

      class << self
        attr_reader :response

        def client
          @client ||= OAI::Client.new(base_urls.first, {}, _proxy)
        end

        def records(options = {})
          options = options.keep_if { |key| VALID_RECORDS_OPTIONS.include?(key) }
          options[:metadata_prefix] = get_metadata_prefix if get_metadata_prefix.present?
          options[:set] = get_set if get_set.present?

          SupplejackCommon::Oai::PaginatedCollection.new(client, options, self)
        end

        def resumption_token
          response.try(:resumption_token)
        end

        def clear_definitions
          super
          SupplejackCommon::Oai::Base._metadata_prefix[identifier] = nil
          SupplejackCommon::Oai::Base._set[identifier] = nil
        end

        def metadata_prefix(prefix)
          _metadata_prefix[identifier] = prefix
        end

        def get_metadata_prefix
          _metadata_prefix[identifier]
        end

        def set(name)
          _set[identifier] = name
        end

        def get_set
          _set[identifier]
        end
      end

      def initialize(xml, from_raw = false)
        @original_xml = xml
        @original_xml = xml.element.to_s if xml.respond_to?(:element)
        super
      end

      def document
        @document ||= begin
          doc = Nokogiri::XML.parse(original_xml)
        end
      end

      def deletable?
        return true if document.xpath("record/header[@status='deleted']").any?

        super
      end
    end
  end
end
