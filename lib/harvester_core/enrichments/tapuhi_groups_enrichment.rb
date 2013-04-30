module HarvesterCore
  class TapuhiGroupsEnrichment < AbstractEnrichment
    def set_attribute_values
      enrich_groups
    end

    def enrich_groups
      unless parent_tap = record.parent_tap_id
        parent = find_record(parent_tap)
        @record_attributes[parent.id][:category] << "Groups"
        @record_attributes[parent.id][:collection_title] << parent.title

        @record_attributes[parent.id][:deletion_list] << Hash.new {|hash,key| hash[key] = Set.new()}
        @record_attributes[parent.id][:deletion_list].first[:category] << "Other"
      end
    end

    class << self
      def before(source_id)
        RestClient.delete "#{ENV["API_HOST"]}/harvester/sources/#{source_id.to_s}.json"
      end
    end

    def enrichable?
      !!record
    end
  end
end