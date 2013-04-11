module Repository
  class Source
    include Mongoid::Document

    embedded_in :record, class_name: "Repository::Record"

    embeds_many :authorities, cascade_callbacks: true, class_name: "Repository::Authority"
  end
end