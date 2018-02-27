# frozen_string_literal: true

module SupplejackCommon
  module XmlDataMethods
    extend ::ActiveSupport::Concern

    def raw_data
      @raw_data ||= document.to_xml
    end

    def full_raw_data
      if self.class._namespaces.present?
        SupplejackCommon::Utils.add_namespaces(raw_data, self.class._namespaces)
      else
        raw_data
      end
    end
  end
end
