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

        options              = Option.get_decompressor_options options
        @native_decompressor = NativeDecompressor.new options

        @source = nil
      end

      def read_magic_header
        # loop do
        #   source = @reader.call
        #   @source << source
        #
        #   processed_source_length = @native_compressor.read_magic_header @source
        #   next if processed_source_length == 0
        #
        #   @source = @source[processed_source_length..-1]
        #
        #   return nil
        # end
      end

      # protected def read_more_source
      #   next_source = @reader.call
      #   raise NotEnoughSourceError if @source.nil? && next_source.nil?
      #
      #   @source = next_source
      #
      #   nil
      # end

      protected def flush_destination_buffer
        result_length = read_result
        raise NotEnoughDestinationError if result_length == 0
      end

      protected def read_result
        result = @native_decompressor.read_result
        @writer.call result

        result.length
      end
    end
  end
end
