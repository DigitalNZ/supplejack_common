module HarvesterCore
  class TapuhiRecordsEnrichment < BaseTapuhiEnrichment

    def set_attribute_values
      denormalise
      build_creator
      relationships
      broad_related_authorities
    end

    protected

    def build_creator
      @attributes[:authorities] ||= []
      
      name_authorities = @attributes[:authorities].find_all { |v| v[:name] == "name_authority" }
      @attributes[:creator] = name_authorities.map { |v| v[:title] }
      
      @attributes[:creator] = @attributes[:creator].empty? ? ["Not specified"] : @attributes[:creator]
    end

    def relationships
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

    def broad_related_authorities
      authorities = []
      [:name_authority, :subject_authority, 
       :iwihapu_authority, :place_authority, :recordtype_authority].each do |type|
        authorities += record.authority_taps(type)
      end
      
      authorities.each do |authority_tap|
        authority = find_record(authority_tap)
        authority.authorities.each do |a|
          if ['broader_term', 'broad_related_authority'].include?(a.name)
            @attributes[:authorities] ||= []
            @attributes[:authorities] << {authority_id: a.authority_id, name: 'broad_related_authority', text: a.text}
          end
        end
      end
      @attributes[:authorities].uniq! if @attributes[:authorities].present?
    end

    private
    
    def build_authorities(parent, intermediates, root)
      @attributes[:authorities] ||= []

      @attributes[:authorities] << {authority_id: parent.tap_id, name: "collection_parent", text: parent.title}
      
      intermediates.each do |i|
        @attributes[:authorities] << {authority_id: i.tap_id, name: "collection_mid", text: i.title}
      end

      @attributes[:authorities] << {authority_id: root.tap_id, name: "collection_root", text: root.title}
    end

    def build_relation(parent)
      @attributes[:relation] ||= []
      @attributes[:relation] << parent.title
      @attributes[:relation] << parent.shelf_location
    end

    def build_is_part_of(root)
      @attributes[:is_part_of] ||= []
      @attributes[:is_part_of] << root.title
      @attributes[:is_part_of] << root.shelf_location
    end
  end
end
