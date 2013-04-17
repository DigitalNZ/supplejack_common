module HarvesterCore
  class TapuhiRelationshipsEnrichment < AbstractEnrichment

    def set_attribute_values
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

        build_authorities(parent, intermediates, root)
        build_relation(root)
        build_is_part_of(parent)
      end
    end

    def enrichable?
      !!record
    end

    private
    
    def build_authorities(parent, intermediates, root)
      @attributes[:authorities] = []

      @attributes[:authorities] << {authority_id: parent.tap_id, name: "collection_parent", text: parent.title}
      
      intermediates.each do |i|
        @attributes[:authorities] << {authority_id: i.tap_id, name: "collection_mid", text: i.title}
      end

      @attributes[:authorities] << {authority_id: root.tap_id, name: "collection_root", text: root.title}
    end

    def build_relation(parent)
      @attributes[:relation] = []
      @attributes[:relation] << parent.title
      @attributes[:relation] << parent.shelf_location
    end

    def build_is_part_of(root)
      @attributes[:is_part_of] = []
      @attributes[:is_part_of] << root.title
      @attributes[:is_part_of] << root.shelf_location
    end
  end
end