module HarvesterCore
  class Loader

    attr_accessor :parser, :load_error, :environment

    def initialize(parser, environment)
      @parser = parser
      @loaded = nil
      @environment = environment.to_s.camelize
    end

    def path
      @path ||= HarvesterCore.parser_base_path + "/#{parser.strategy}/#{parser.file_name}"
    end

    def content_with_encoding
      "# encoding: utf-8\r\nmodule LoadedParser::#{environment}\n" + parser.content.to_s + "\nend"
    end

    def create_tempfile
      FileUtils.mkdir_p("#{HarvesterCore.parser_base_path}/#{parser.strategy}")
      File.open(path, "w") {|f| f.write(content_with_encoding) }
    end

    def parser_class_name
      parser.name.gsub(/\s/, "_").camelize
    end

    def parser_class_name_with_module
      "LoadedParser::#{environment}::" + parser_class_name
    end

    def parser_class
      "LoadedParser::#{environment}::#{parser_class_name}".constantize
    end

    def load_parser
      return @loaded unless @loaded.nil?

      create_tempfile
      clear_parser_class_definitions
      load(path)
      @loaded = true
    end

    def loaded?
      load_parser
      @loaded
    end

    def clear_parser_class_definitions
      mod = "LoadedParser::#{environment}".constantize
      if mod.const_defined?(parser_class_name, false)
        parser_class.clear_definitions
        mod.send(:remove_const, parser_class_name.to_sym)
      end
    end
  end
end
