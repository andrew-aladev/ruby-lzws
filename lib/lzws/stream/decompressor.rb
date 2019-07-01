# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "lzws_ext"

require_relative "../error"
require_relative "../option"
require_relative "../validation"

module LZWS
  module Stream
    class Decompressor
      def initialize(reader, writer, options = {})
        Validation.validate_proc reader
        @reader = reader

        Validation.validate_proc writer
        @writer = writer

        options = Option.get_decompressor_options options

        @native_decompressor = NativeDecompressor.new options

        @source = ""
      end

      def read_magic_header
        # @source = @reader.call
        #
        # processed_source_length = @native_compressor.read_magic_header source
        # if processed_source_length.zero?
        # end

        # loop do
        # end

        nil
      end

      protected def flush_destination_buffer
        result_length = write_result
        raise NotEnoughDestinationBufferError if result_length == 0
      end

      protected def write_result
        result = @native_decompressor.read_result
        @writer.call result

        result.length
      end
    end
  end
end
