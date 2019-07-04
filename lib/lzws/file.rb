# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "lzws_ext"

require_relative "error"
require_relative "option"
require_relative "validation"

module LZWS
  module File
    def self.compress(source, destination, options = {})
      Validation.validate_string source
      Validation.validate_string destination

      options = Option.get_compressor_options options

      open_files(source, destination) do |source_io, destination_io|
        LZWS._native_compress_io source_io, destination_io, options
      end
    end

    def self.decompress(source, destination, options = {})
      Validation.validate_string source
      Validation.validate_string destination

      options = Option.get_decompressor_options options

      open_files(source, destination) do |source_io, destination_io|
        LZWS._native_decompress_io source_io, destination_io, options
      end
    end

    private_class_method def self.open_files(source, destination, &_block)
      open_file(source, "rb") do |source_io|
        open_file(destination, "wb") do |destination_io|
          yield source_io, destination_io
        end
      end
    end

    private_class_method def self.open_file(path, mode, &_block)
      begin
        io = ::File.open path, mode
      rescue StandardError
        raise OpenFileError, "open file failed"
      end

      begin
        yield io
      ensure
        io.close
      end
    end
  end
end
