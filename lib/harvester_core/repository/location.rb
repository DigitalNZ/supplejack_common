module Repository
  class Location
    include Mongoid::Document

    embedded_in :source, class_name: "Repository::Source"

  end
end