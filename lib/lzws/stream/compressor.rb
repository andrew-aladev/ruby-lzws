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

        options = Option.get_compressor_options options

        @native_compressor = NativeCompressor.new options
      end

      def write_magic_header
        loop do
          is_finished = @native_compressor.write_magic_header
          return nil if is_finished

          flush_destination_buffer
        end
      end

      def write
        source = @reader.call

        loop do
          break if source.nil?

          processed_source_length = @native_compressor.write source
          if processed_source_length == source.length
            source = @reader.call
            next
          end

          source = source[processed_source_length..-1]
          flush_destination_buffer
        end

        flush

        nil
      end

      protected def flush
        loop do
          is_finished = @native_compressor.flush
          if is_finished
            write_result
            return nil
          end

          flush_destination_buffer
        end
      end

      protected def flush_destination_buffer
        result_length = write_result
        raise NotEnoughDestinationBufferError if result_length == 0
      end

      protected def write_result
        result = @native_compressor.read_result
        @writer.call result

        result.length
      end
    end
  end
end
