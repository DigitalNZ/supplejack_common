module HarvesterCore
  module Oai
    class Base < HarvesterCore::Base
      include HarvesterCore::XmlMethods

      self.clear_definitions

      VALID_RECORDS_OPTIONS = [:from, :limit]

      attr_reader :original_xml

      class << self
        attr_reader :response

        def client
          @client ||= OAI::Client.new(self.base_urls.first)
        end

        def records(options={})
          options = options.keep_if {|key| VALID_RECORDS_OPTIONS.include?(key) }
          HarvesterCore::Oai::PaginatedCollection.new(client, options, self)
        end

        def resumption_token
          self.response.try(:resumption_token)
        end
      end

      def initialize(xml, from_raw=false)
        @original_xml = xml
        @original_xml = xml.element.to_s if xml.respond_to?(:element)
        super
      end

      def document
        @document ||= begin
          xml = HarvesterCore::Utils.remove_default_namespace(original_xml)
          doc = Nokogiri::XML.parse(xml)
          doc.remove_namespaces!
          doc
        end
      end
    end
  end
end
