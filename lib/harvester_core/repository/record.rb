module Repository
  class Record
    include Mongoid::Document
    
    embeds_many :sources, cascade_callbacks: true, class_name: "Repository::Source"

    store_in collection: "records", session: "api"

    delegate :title, to: :primary

    default_scope where(status: "active")

    def primary
      self.sources.where(priority: 0).first
    end

    def parent_tap_id
      extract_tap_id(:relation)
    end

    def tap_id
      extract_tap_id(:dc_identifier)
    end

    private

    def extract_tap_id(field)
      tap_id = Array(primary[field]).find {|id| id.match(/tap:/) }
      tap_number = tap_id.to_s.match(/\d+/)
      tap_number ? tap_number[0].to_i : nil
    end
  end
end