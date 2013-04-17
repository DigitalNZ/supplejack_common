module HarvesterCore
  class TapuhiAuthoritiesEnrichment < BaseTapuhiEnrichment

    def set_attribute_values
      denormalise
      broad_related_authorities
    end

    def enrichable?
      !!record
    end

    protected
    
    def broad_related_authorities
      parents = record.authority_taps(:broader_term)

      parents.each do |parent_tap|
        parent = find_record(parent_tap)

        iteration_count = 0
        processed_ancestors = []
        queued_ancestors = parent.authority_taps(:broader_term)

        while ancestor_tap = queued_ancestors.shift
          iteration_count += 1
          raise "Iteration is too deep (#{iteration_count}) for record #{record.record_id}" if iteration_count >= 15
          
          ancestor = find_record(ancestor_tap)
          
          @attributes[:authorities] ||= []
          @attributes[:authorities] << {authority_id: ancestor.tap_id, name: "broad_related_authority", text: ancestor.title}
          processed_ancestors << ancestor.tap_id

          queued_ancestors += ancestor.authority_taps(:broader_term)
          queued_ancestors.uniq!
          queued_ancestors -= (processed_ancestors+parents)
        end
      end
    end
  end
end