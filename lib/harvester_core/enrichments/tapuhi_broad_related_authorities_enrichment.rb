module HarvesterCore
  class TapuhiBroadRelatedAuthoritiesEnrichment < AbstractEnrichment
  	def set_attribute_values
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

    def enrichable?
      !!record
    end
  end
end