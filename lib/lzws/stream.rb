# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "lzws_ext"

require_relative "error"
require_relative "file"
require_relative "option"

module LZWS
  module Stream
    class Writer < Streamer
      def initialize(destination_io, options = {})
        Stream.validate_io destination_io

        options = Option.get_compressor_options options
      end

      def self.open_file(path, options, &_block)
        Stream.validate_string path

        File.open_file path, "wb" do |io|
          yield new(io, options)
        end
      end
    end

    class Reader
      def initialize(source_io, options = {})
        Stream.validate_io source_io

        options = Option.get_decompressor_options options
      end

      def self.open_file(path, options, &_block)
        Stream.validate_string path

        File.open_file path, "rb" do |io|
          yield new(io, options)
        end
      end
    end

    def self.validate_io(io)
      raise ValidateError unless io.is_a? ::IO
    end

    def self.validate_string(string)
      raise ValidateError unless string.is_a? ::String
    end
  end
end
