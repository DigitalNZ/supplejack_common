# The Supplejack Common code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack_core 

class TapuhiParser < SupplejackCommon::Tapuhi::Base
  base_url "/path/to/source_file.tap"

  attribute :content_partner, default: "Alexander Turnbull Library"

  attribute :title, field_num: 2
  attribute :dc_type, field_num: 1

end