module DnzHarvester
  module Sitemap
    class Base < DnzHarvester::Base

      self._base_urls = []
      self._attribute_definitions = {}

      class << self
        def sitemap_file
          @@sitemap_file ||= File.read(self._base_urls.first)
        end

        def sitemap_document
          @@sitemap_document ||= Nokogiri.parse(sitemap_file)
        end

        def record_urls
          sitemap_document.remove_namespaces!
          sitemap_document.xpath("//loc").map(&:text)
        end

        def records
          @@records ||= record_urls.map do |url|
            new(url)
          end
        end
      end

      def initialize(url)
        @url = url
        super
      end

      def fetch_record_xml
        @record_xml ||= RestClient.get(@url)
      end

      def document
        @document ||= Nokogiri.parse(fetch_record_xml)
      end

      def set_attribute_values
        self.class._attribute_definitions.each do |attribute_name, options|
          options ||= {}
          value = nil

          if options[:default]
            value = options[:default]
          elsif options[:xpath] && options[:if]
            value = conditional_value(options)
          elsif options[:xpath] && options[:mappings]
            value = mappings_value(options)
          elsif options[:xpath] && options[:value]
            xpath_expressions = *options[:xpath]
            value = xpath_expressions.map {|e| document.xpath("//#{e}/@#{options[:value]}").text }
          elsif options[:xpath]
            value = document.xpath("//#{options[:xpath]}").map(&:text)
          elsif options.empty?
            value = document.xpath("//#{attribute_name}").map(&:text)
          end

          @original_attributes[attribute_name] = value
        end

        @original_attributes
      end

      def conditional_value(options)
        value = nil
        nodes = document.xpath("//#{options[:xpath]}")
        nodes.each do |node|
          node_text = node.xpath(options[:if].keys.first).text
          conditional_values = options[:if].values.flatten
          if node_text.present? && conditional_values.include?(node_text)
            value = node.xpath(options[:value]).text
            break
          end
        end

        value
      end

      def mappings_value(options)
        value = nil
        xpath_query = "//#{options[:xpath]}"
        xpath_query << "/@#{options[:value]}" if options[:value].present?
        value = document.xpath(xpath_query).text
        options[:mappings].each do |regex, new_value|
          if value.match(/#{regex}/)
            value = new_value
            break
          end
        end

        value
      end
    end
  end
end