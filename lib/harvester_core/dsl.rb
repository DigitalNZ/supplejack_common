module HarvesterCore
  module DSL
    extend ActiveSupport::Concern

    included do
      class_attribute :_base_urls
      class_attribute :_attribute_definitions
      class_attribute :_enrichment_definitions
      class_attribute :_basic_auth
      class_attribute :_pagination_options
      class_attribute :_rejection_rules
      class_attribute :_deletion_rules
      class_attribute :_throttle
      class_attribute :_environment
      class_attribute :_priority

      self._base_urls = {}
      self._attribute_definitions = {}
      self._enrichment_definitions = {}
      self._basic_auth = {}
      self._pagination_options = {}
      self._rejection_rules = {}
      self._deletion_rules = {}
      self._environment = {}
      self._priority = {}
    end

    module ClassMethods

      # DEPRECATED: source_id is no longer defined in the parser. 
      # This method stub exists to smooth the transition for existing parser
      # Needs to be removed soon - 2013-09-17
      def source_id(id)
      end

      def base_url(url)
        self._base_urls[self.identifier] ||= []
        self._base_urls[self.identifier] += [url]
      end

      def basic_auth(username, password)
        self._basic_auth[self.identifier] = {username: username, password: password}
      end

      def paginate(options={})
        self._pagination_options[self.identifier] = options
      end

      def attribute(name, options={}, &block)
        self._attribute_definitions[self.identifier] ||= {}
        self._attribute_definitions[self.identifier][name] = options || {}

        self._attribute_definitions[self.identifier][name][:block] = block if block_given?
      end

      def attributes(*args, &block)
        options = args.extract_options!

        args.each do |attribute|
          self.attribute(attribute, options, &block)
        end
      end

      def enrichment(name, options={}, &block)
        self._enrichment_definitions[self.identifier] ||= {}
        self._enrichment_definitions[self.identifier][name] = options || {}

        self._enrichment_definitions[self.identifier][name][:block] = block if block_given?
      end

      def with_options(options={}, &block)
        yield(HarvesterCore::Scope.new(self, options))
      end

      def reject_if(&block)
        self._rejection_rules[self.identifier] ||= []
        self._rejection_rules[self.identifier] += [block]
      end

      def delete_if(&block)
        self._deletion_rules[self.identifier] = block
      end

      def throttle(options={})
        self._throttle ||= []
        self._throttle << options
      end

      def priority(priority)
        self._priority[self.identifier] = priority
      end
    end
  end
end