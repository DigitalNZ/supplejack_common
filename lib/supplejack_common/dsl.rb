# frozen_string_literal: true

module SupplejackCommon
  # DSLs for supplejack
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
      class_attribute :_request_timeout
      class_attribute :_environment
      class_attribute :_priority
      class_attribute :_match_concepts
      class_attribute :_http_headers
      class_attribute :_proxy
      class_attribute :_pre_process_block

      self._base_urls = {}
      self._attribute_definitions = {}
      self._enrichment_definitions = {}
      self._basic_auth = {}
      self._pagination_options = {}
      self._rejection_rules = {}
      self._deletion_rules = {}
      self._environment = {}
      self._priority = {}
      self._request_timeout = nil
      self._match_concepts = {}
      self._http_headers = {}
      self._proxy = nil
      self._pre_process_block = nil
    end

    module ClassMethods
      # DEPRECATED: source_id is no longer defined in the parser.
      # This method stub exists to smooth the transition for existing parser
      # Needs to be removed soon - 2013-09-17
      def source_id(id); end

      def base_url(url)
        _base_urls[identifier] ||= []
        _base_urls[identifier] += [url]
      end

      # This takes a hash of HTTP headers
      # eg { 'Authorization': 'something', 'api-key': 'somekey' }
      def http_headers(headers)
        self._http_headers = headers
      end

      def basic_auth(username, password)
        _basic_auth[identifier] = { username: username, password: password }
      end

      def paginate(options = {}, &block)
        _pagination_options[identifier] = options || {}
        _pagination_options[identifier][:block] = block if block_given?
      end

      def attribute(name, options = {}, &block)
        _attribute_definitions[identifier] ||= {}
        _attribute_definitions[identifier][name] = options || {}

        _attribute_definitions[identifier][name][:block] = block if block_given?
      end

      def attributes(*args, &block)
        options = args.extract_options!

        args.each do |attribute|
          self.attribute(attribute, options, &block)
        end
      end

      def enrichment(name, options = {}, &block)
        _enrichment_definitions[identifier] ||= {}
        _enrichment_definitions[identifier][name] = options || {}

        _enrichment_definitions[identifier][name][:block] = block if block_given?
      end

      def with_options(options = {})
        yield(SupplejackCommon::Scope.new(self, options))
      end

      def reject_if(&block)
        _rejection_rules[identifier] ||= []
        _rejection_rules[identifier] += [block]
      end

      def delete_if(&block)
        _deletion_rules[identifier] = block
      end

      def throttle(options = {})
        self._throttle ||= []
        self._throttle << options
      end

      def request_timeout(timeout)
        self._request_timeout = timeout
      end

      def priority(priority)
        _priority[identifier] = priority
      end

      def match_concepts(match_concepts)
        _match_concepts[identifier] = match_concepts
      end

      def proxy(url)
        self._proxy = url
      end

      def pre_process_block(&block)
        self._pre_process_block = block
      end
    end
  end
end
