class TapuhiParser < HarvesterCore::Tapuhi::Base
  base_url "/path/to/source_file.tap"

  attribute :content_partner, default: "Alexander Turnbull Library"

  attribute :title, field_num: 2
  attribute :dc_type, field_num: 1

end