module Repository
  class Authority
    include Mongoid::Document

    embedded_in :source, class_name: "Repository::Source"

    field :text, type: String
  end
end