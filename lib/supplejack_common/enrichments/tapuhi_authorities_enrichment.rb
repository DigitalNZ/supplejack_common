# The Supplejack Common code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack_core 

module SupplejackCommon
  class TapuhiAuthoritiesEnrichment < BaseTapuhiEnrichment

    def set_attribute_values
      denormalise
      broad_related_authorities
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
          raise "Iteration is too deep (#{iteration_count}) for record #{record.record_id}" if iteration_count >= 100
          
          ancestor = find_record(ancestor_tap)

          unless ancestor.nil?
            attributes[:authorities] << {authority_id: ancestor.tap_id, name: "broad_related_authority", text: ancestor.title}
            processed_ancestors << ancestor.tap_id

            queued_ancestors += ancestor.authority_taps(:broader_term)
            queued_ancestors.uniq!
            queued_ancestors -= (processed_ancestors+parents)
          end
        end
      end
    end
  end
end