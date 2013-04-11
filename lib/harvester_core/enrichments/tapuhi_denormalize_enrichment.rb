module HarvesterCore
  class TapuhiDenormalizeEnrichment < AbstractEnrichment

    def set_attribute_values
      authorities = primary[:authorities]

      unless authorities.to_a.empty?
        @attributes[:authorities] = []

        authorities.to_a.each do |authority|
          record = find_record(authority["authority_id"])
          if record
            @attributes[:authorities] << {authority_id: authority["authority_id"], name: authority["name"], role: authority["role"], text: record.title}
          end
        end
      end
    end

    def enrichable?
      !!record
    end
  end
end