# frozen_string_literal: true

require 'dimensions'
require 'mimemagic'

module SupplejackCommon
  class FileResource < Resource
    def document
      @document ||= begin
        file = Tempfile.new('small_image')
        file.binmode
        file.write(fetch_document)
        file
      end
    end

    def attributes
      return @attributes unless @attributes.empty?

      %i[size height width mime_type extension url].each do |attribute|
        @attributes[attribute] = send(attribute)
      end

      @attributes
    end

    def size
      document.size
    end

    def dimensions
      # Dimensions gem doesn't yet have the ability to read a file from memory, so we have to flush the
      # contents of the Tempfile to the OS so that it reads the dimensions correctly
      @dimensions ||= if document
                        document.flush
                        Dimensions.dimensions(document)
                      end
    end

    def height
      dimensions[1]
    end

    def width
      dimensions[0]
    end

    def mime_magic
      @mime_magic ||= MimeMagic.by_path(url) || MimeMagic.by_magic(document)
    end

    def mime_type
      mime_magic.try(:mediatype)
    end

    def extension
      extension = File.extname(url)[1..-1].to_s.downcase

      unless extension.length.between?(1, 5)
        extensions = mime_magic.try(:extensions) || []
        extensions.delete('jpe')
        extension = extensions.first
      end
      extension
    end

    def fetch(value)
      public_send(value.to_sym)
    end

    def strategy_value(options)
      fetch(options[:field]) if options[:field].present?
    end
  end
end
