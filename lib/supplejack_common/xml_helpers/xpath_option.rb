# The Supplejack Common code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack 
require 'sanitize'

module SupplejackCommon
  class XpathOption
    attr_reader :document, :options, :namespace_definitions

    def initialize(document, options, namespace_definitions={})
      @document = document
      @options = options
      @namespace_definitions = namespace_definitions || {}
      @default_sanitization_config = Sanitize::Config.merge(Sanitize::Config::DEFAULT, whitespace_elements: [])
    end

    def value
      return nodes if options[:object]

      if nodes.is_a?(Array)
        nodes.map(&method(:extract_node_value))
      else
        extract_node_value(nodes)
      end
    end

    private

    def nodes
      return [] unless options[:xpath].present?
      xpath_expressions = Array(options[:xpath])
      @nodes = []

      xpath_expressions.each do |xpath|
        @nodes += document.xpath("#{xpath_value(xpath)}", namespace_definitions)
      end

      @nodes
    end

    def extract_node_value(node)
      Sanitize.fragment(node.to_html, options[:sanitize_config] || @default_sanitization_config).strip
    end

    def xpath_value(xpath)
      xpath = ".#{xpath}" if document.is_a?(Nokogiri::XML::NodeSet) || document.is_a?(Nokogiri::XML::Element)
      xpath
    end
  end
end
