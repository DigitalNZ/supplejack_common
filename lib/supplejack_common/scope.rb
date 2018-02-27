# frozen_string_literal: true

module SupplejackCommon
  # Scope Class
  class Scope
    def initialize(klass, options)
      @klass = klass
      @scope_options = options
    end

    def attribute(name, options = {})
      new_options = @scope_options.dup
      if_options = new_options[:if]

      if if_options.is_a?(Hash)
        new_options[:if] = Hash[if_options.map do |key, value|
          value = options.values.first if options.keys.first == value
          [key, value]
        end]
      end

      @klass.send(:attribute, name, new_options)
    end

    def attributes(*args)
      options = args.extract_options!

      args.each do |attribute|
        self.attribute(attribute, options)
      end
    end
  end
end
