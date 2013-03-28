module HarvesterCore
  class AbstractEnrichment

    attr_accessor :errors
    attr_reader :name, :record, :attributes, :parser_class

    def initialize(name, options, record, parser_class)
      @name = name
      @record = record
      @parser_class = parser_class
      @attributes = {}
      @errors = {}
      @attributes[:priority] = options[:priority] || 1
    end

    def primary
      @primary ||= HarvesterCore::SourceWrap.new(record.sources.where(priority: 0).first)
    end

    def set_attribute_values
      raise NotImplementedError.new("All subclasses of HarvesterCore::AbstractEnrichment must override #set_attribute_values.")
    end

    def enrichable?
      raise NotImplementedError.new("All subclasses of HarvesterCore::AbstractEnrichment must override #enrichable?.")
    end
    
    private

    def find_record(tap_id)
      return nil unless tap_id.present?
      record.class.where("sources.dc_identifier" => "tap:#{tap_id}").first
    end
  end
end