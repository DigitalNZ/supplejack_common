# The Supplejack Common code is
# Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# See https://github.com/DigitalNZ/supplejack for details.
#
# Supplejack was created by DigitalNZ at the
# National Library of NZ and the Department of Internal Affairs.
# http://digitalnz.org/supplejack

module SupplejackCommon
  # BaseTapuhiEnrichment Class
  class BaseTapuhiEnrichment < AbstractEnrichment

    def enrichable?
      !!record
    end

    protected
    
    def denormalise
      authorities = primary[:authorities]

      unless authorities.to_a.empty?
        authorities.to_a.each do |authority|
          record = find_record(authority['authority_id'])
          if record
            attributes[:authorities] << {authority_id: authority['authority_id'], name: authority['name'], role: authority['role'], text: record.title}
          end
        end
      end
    end
  end
end
