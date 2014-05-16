# The Supplejack code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack_core 

module HarvesterCore
  class Scope

    def initialize(klass, options)
      @klass = klass
      @scope_options = options
    end

    def attribute(name, options={})
      new_options = @scope_options.dup
      if_options = new_options[:if]

      if if_options.is_a?(Hash)
        new_options[:if] = Hash[if_options.map { |key, value|
          value = options.values.first if options.keys.first == value
          [key, value]
        }]
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