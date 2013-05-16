module Repository
  class PreviewRecord < Record
  	store_in collection: "preview_records", session: "api"
  end
end