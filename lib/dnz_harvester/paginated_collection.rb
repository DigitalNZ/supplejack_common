module DnzHarvester
  class PaginatedCollection
    
    def initialize(records)
      @records = records
    end

    def records
      @records
    end

    def method_missing(name, *args, &block)
      records.send(name, *args, &block)
    end
  end
end