module Repository
  class Source
    include Mongoid::Document

    embedded_in :record, class_name: "Repository::Record"
  end
end