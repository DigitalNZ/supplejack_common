module DnzHarvester
  class AbstractOption
      
    attr_reader :document, :options

    def initialize(document, options)
      @document = document
      @options = options
    end

    def nodes
      return [] unless options[:xpath].present?
      xpath_expressions = Array(options[:xpath])
      @nodes = []

      xpath_expressions.each do |xpath|
        @nodes += document.xpath("//#{xpath}")
      end

      @nodes
    end
  end
end