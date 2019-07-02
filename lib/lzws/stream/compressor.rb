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

        @source = nil
      end

      def write_magic_header
        loop do
          is_finished = @native_compressor.write_magic_header
          return nil if is_finished

          flush_destination_buffer
        end
      end

      # Write eats all source bytes.
      # If it can't eat something - we need to flush destination.

      def write
        read_next_source

        loop do
          break if @source.nil?

          processed_source_length = @native_compressor.write @source
          if processed_source_length == @source.length
            read_next_source
            next
          end

          @source = @source[processed_source_length..-1]
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

      protected def read_next_source
        next_source = @reader.call
        raise NotEnoughSourceError if @source.nil? && next_source.nil?

        @source = next_source

        nil
      end

      protected def flush_destination_buffer
        result_length = write_result
        raise NotEnoughDestinationError if result_length == 0
      end

      protected def write_result
        result = @native_compressor.read_result
        @writer.call result

        result.length
      end
    end
  end
end
