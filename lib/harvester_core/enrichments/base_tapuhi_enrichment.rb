module HarvesterCore
  class BaseTapuhiEnrichment < AbstractEnrichment

    protected
    def denormalise
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
    
  end
end