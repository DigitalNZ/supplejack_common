module Repository
  class Record
    include Mongoid::Document
    
    embeds_many :sources, cascade_callbacks: true, class_name: "Repository::Source"

    store_in collection: "records", session: "api"

    delegate :title, :shelf_location, to: :primary

    default_scope where(status: "active")

    def primary
      self.sources.where(priority: 0).first
    end

    def parent_tap_id
      extract_tap_id(:is_part_of)
    end

    def tap_id
      extract_tap_id(:dc_identifier)
    end

    def authority_taps(name)
      primary.authorities.map {|authority| authority.authority_id if authority.name == name.to_s }.compact
    end

    def authorities
      authorities = {}
      sorted_sources.each do |source|
        source.authorities.each do |authority|
          authorities["#{authority.authority_id}-#{authority.name}"] ||= authority
        end
      end
      authorities.values
    end

    private

    def sorted_sources
      self.sources.sort_by {|s| s.priority || Integer::INT32_MAX }
    end

    def extract_tap_id(field)
      tap_id = Array(primary[field]).find {|id| id.match(/tap:/) }
      tap_number = tap_id.to_s.match(/\d+/)
      tap_number ? tap_number[0].to_i : nil
    end
  end
end