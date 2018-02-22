module SupplejackCommon
  module Dsl
    module Sitemap
      extend ActiveSupport::Concern

      included do
        class_attribute :_sitemap_entry_selector
      end

      module ClassMethods
        def sitemap_entry_selector(xpath)
          self._sitemap_entry_selector = xpath
        end
      end
    end
  end
end
