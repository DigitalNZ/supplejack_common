# frozen_string_literal: true

require 'sanitize'
require 'htmlentities'

module SupplejackCommon
  class XpathOption
    attr_reader :document, :options, :namespace_definitions

    def initialize(document, options, namespace_definitions = {})
      @document = document
      @options = options
      @namespace_definitions = namespace_definitions || {}
      @default_sanitization_config = Sanitize::Config.merge(Sanitize::Config::DEFAULT, whitespace_elements: [])
    end

    def value
      return nodes if options[:object]

      strategies = {
        custom_sanitize: lambda {
          if nodes.is_a?(Array)
            nodes.map(&method(:extract_node_value))
          else
            extract_node_value(nodes)
          end
        },
        normal: lambda {
          if nodes.is_a?(Array)
            nodes.map(&:text)
          else
            nodes.text
          end
        }
      }
      strategy = options[:sanitize_config] ? :custom_sanitize : :normal

      strategies[strategy].call
    end

    private

    def nodes
      return [] unless options[:xpath].present?
      xpath_expressions = Array(options[:xpath])
      @nodes = []

      xpath_expressions.each do |xpath|
        @nodes += document.xpath(xpath_value(xpath).to_s, namespace_definitions)
      end

      @nodes
    end

    def extract_node_value(node)
      sanitized_value = Sanitize.fragment(node.to_html, options[:sanitize_config] || @default_sanitization_config).strip
      decoded_value = HTMLEntities.new.decode sanitized_value

      decoded_value
    end

    def xpath_value(xpath)
      xpath = ".#{xpath}" if document.is_a?(Nokogiri::XML::NodeSet) || document.is_a?(Nokogiri::XML::Element)
      xpath
    end
  end
end
