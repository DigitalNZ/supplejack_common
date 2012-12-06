module DnzHarvester
  class RecordsContainer
    
    def initialize(records)
      @records = records
    end

    def records
      @records
    end

    def deletions
      []
    end

    def method_missing(name, *args, &block)
      records.send(name, *args, &block)
    end
  end
end