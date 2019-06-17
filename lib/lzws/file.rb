# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "lzws_ext"

require_relative "error"
require_relative "option"

module LZWS
  module File
    def self.validate_arguments(source, destination)
      raise UnexpectedArgumentError unless source.is_a?(::String) && destination.is_a?(::String)
    end

    def self.open_file(path, mode, &_block)
      begin
        io = File.open path, mode
      rescue StandardError
        raise OpenFileError
      end

      begin
        yield io
      ensure
        io.close
      end
    end

    def self.open_files(source, destination, &_block)
      open_file(source, "r") do |source_io|
        open_file(destination, "w") do |destination_io|
          yield source_io, destination_io
        end
      end
    end

    def self.compress(source, destination, options = {})
      validate_arguments source, destination

      options = Option.get_compressor_options options

      open_files(source, destination) do |source_io, destination_io|
        LZWS._compress_io source_io, destination_io, options
      end
    end

    def self.decompress(source, destination, options = {})
      validate_arguments source, destination

      options = Option.get_decompressor_options options

      open_files(source, destination) do |source_io, destination_io|
        LZWS._decompress_io source_io, destination_io, options
      end
    end
  end
end
