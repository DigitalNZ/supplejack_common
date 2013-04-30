module HarvesterCore
  class Loader

    attr_accessor :parser, :load_error

    def initialize(parser)
      @parser = parser
      @loaded = nil
    end

    def path
      @path ||= HarvesterCore.parser_base_path + "/#{parser.strategy}/#{parser.file_name}"
    end

    def content_with_encoding
      "# encoding: utf-8\r\n" + parser.content.to_s
    end

    def create_tempfile
      FileUtils.mkdir_p("#{HarvesterCore.parser_base_path}/#{parser.strategy}")
      File.open(path, "w") {|f| f.write(content_with_encoding) }
    end

    def parser_class_name
      parser.name.gsub(/\s/, "_").camelize
    end

    def parser_class
      parser_class_name.constantize
    end

    def load_parser
      return @loaded unless @loaded.nil?

      begin
        create_tempfile
        clear_parser_class_definitions
        load(path)
        @loaded = true
      rescue StandardError, ScriptError => e
        puts "Error: #{e.message}"
        @load_error = e.message
        @loaded = false
      end
    end

    def loaded?
      load_parser
      @loaded
    end

    def clear_parser_class_definitions
      if Object.const_defined?(parser_class_name)
        parser_class.clear_definitions
        Object.send(:remove_const, parser_class_name.to_sym)
      end
    end
  end
end