module HarvesterCore
  class AbstractEnrichment

    attr_accessor :errors
    attr_reader :name, :record, :record_attributes, :parser_class

    def initialize(name, options, record, parser_class)
      @name = name
      @source_id = name
      @record = record
      @parser_class = parser_class
      @record_attributes = Hash.new do |hash, key|
        hash[key] = Hash.new {|hash, key| hash[key] = Set.new()}
        hash[key][:priority] = options[:priority] || 1
        hash[key][:source_id] = self.name.to_s
        hash[key]
      end
      @errors = {}
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

    def attributes
      @record_attributes[record.id]
    end

    # these hooks are called before and after Enrichment job
    class << self
      def before(source_id); end
      def after(source_id); end
    end
    
    private

    #change to internal identifier?
    def find_record(tap_id)
      return nil unless tap_id.present?
      record.class.where("sources.dc_identifier" => "tap:#{tap_id}").first
    end
  end
end