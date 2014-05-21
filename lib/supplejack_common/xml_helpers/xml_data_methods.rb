# The Supplejack Common code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack_core 

module SupplejackCommon
  module XmlDataMethods
    extend ::ActiveSupport::Concern

    def raw_data
      @raw_data ||= self.document.to_xml
    end

    def full_raw_data
      if self.class._namespaces.present?
        SupplejackCommon::Utils.add_namespaces(raw_data, self.class._namespaces)
      else
        self.raw_data
      end
    end
    
  end
end