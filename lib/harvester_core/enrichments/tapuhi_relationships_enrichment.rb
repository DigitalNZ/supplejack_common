module HarvesterCore
  class TapuhiRelationshipsEnrichment < AbstractEnrichment

    def set_attribute_values
      @attributes[:source_id] = self.name.to_s

      parent = find_record(record.parent_tap_id)
      
      intermediates = []

      if parent
        new_parent = parent
        while new_parent = find_record(new_parent.parent_tap_id)
          intermediates << new_parent
        end

        if intermediates.any?
          root = intermediates.pop
        else
          root = parent
        end

        @attributes[:authorities] = []
        @attributes[:authorities] << {authority_id: parent.tap_id, name: "collection_parent", text: parent.title}

        intermediates.each do |i|
          @attributes[:authorities] << {authority_id: i.tap_id, name: "collection_mid", text: i.title}
        end

        @attributes[:authorities] << {authority_id: root.tap_id, name: "collection_root", text: root.title}
      end
    end

    def enrichable?
      !!record
    end

  end
end