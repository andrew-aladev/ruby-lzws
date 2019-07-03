# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "lzws_ext"

require_relative "../error"
require_relative "../option"
require_relative "../validation"

module LZWS
  module Stream
    class Compressor
      def initialize(reader, writer, options = {})
        Validation.validate_proc reader
        @reader = reader

        Validation.validate_proc writer
        @writer = writer

        options            = Option.get_compressor_options options
        @native_compressor = NativeCompressor.new options
      end

      def write_magic_header
        loop do
          need_more_destination = @native_compressor.write_magic_header
          if need_more_destination
            flush_destination_buffer
            next
          end

          return nil
        end
      end

      def write
        source = @reader.call
        raise NotEnoughSourceError if source.nil?

        loop do
          read_length, need_more_destination = @native_compressor.write source
          if need_more_destination
            flush_destination_buffer
            source = source[read_length..-1]
            next
          end

          source = @reader.call
          break if source.nil?
        end

        flush

        nil
      end

      protected def flush
        loop do
          need_more_destination = @native_compressor.flush
          if need_more_destination
            flush_destination_buffer
            next
          end

          read_result
          return nil
        end
      end

      protected def flush_destination_buffer
        result_length = read_result
        raise NotEnoughDestinationError if result_length == 0
      end

      protected def read_result
        result = @native_compressor.read_result
        @writer.call result

        result.length
      end
    end
  end
end
