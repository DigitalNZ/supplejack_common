# frozen_string_literal: true

module SupplejackCommon
  #  AbstractEnrichment Class
  class AbstractEnrichment
    attr_accessor :errors
    attr_reader :name, :record, :record_attributes, :parser_class

    def initialize(name, options, record, parser_class)
      @name = name
      @source_id = name
      @record = record
      @parser_class = parser_class
      @record_attributes = Hash.new do |hash, key|
        hash[key] = Hash.new { |hash, key| hash[key] = Set.new }
        hash[key][:priority] = options[:priority] || 1
        hash[key][:source_id] = self.name.to_s
        hash[key]
      end
      @errors = {}
    end

    def primary
      @primary ||= SupplejackCommon::FragmentWrap.new(record.fragments.select { |f| f.priority.zero? }.first)
    end

    def record_fragment(source_id)
      SupplejackCommon::FragmentWrap.new(record.fragments.select { |f| f.source_id == source_id }.first)
    end

    def set_attribute_values
      raise NotImplementedError, 'All subclasses of SupplejackCommon::AbstractEnrichment must override #set_attribute_values.'
    end

    def enrichable?
      raise NotImplementedError, 'All subclasses of SupplejackCommon::AbstractEnrichment must override #enrichable?.'
    end

    def attributes
      @record_attributes[record.id]
    end

    # these hooks are called before and after Enrichment job
    class << self
      def before(source_id); end

      def after(source_id); end
    end
  end
end
