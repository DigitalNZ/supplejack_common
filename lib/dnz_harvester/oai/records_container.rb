module DnzHarvester
  module Oai
    class RecordsContainer < DnzHarvester::RecordsContainer
      
      def records
        @records.find_all {|r| !r.deleted? }
      end

      def deletions
        @records.find_all {|r| r.deleted? }
      end
    end
  end
end