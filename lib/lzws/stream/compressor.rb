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

        @is_destroyed = false
      end

      def write_magic_header
        raise UsedAfterDestroyError, "compressor used after destroy" if @is_destroyed

        loop do
          need_more_destination = @native_compressor.write_magic_header

          if need_more_destination
            flush_destination_buffer
            next
          end

          break
        end

        nil
      end

      def write
        raise UsedAfterDestroyError, "compressor used after destroy" if @is_destroyed

        source = @reader.call
        raise NotEnoughSourceError, "not enough source" if source.nil?

        loop do
          read_length, need_more_destination = @native_compressor.write source

          if need_more_destination
            source = source[read_length..-1]
            flush_destination_buffer
            next
          end

          if read_length != source.length
            # Compressor write should eat all provided bytes without remainder.
            raise UnexpectedError, "unexpected error"
          end

          source = @reader.call
          break if source.nil?
        end

        nil
      end

      def flush
        raise UsedAfterDestroyError, "compressor used after destroy" if @is_destroyed

        loop do
          need_more_destination = @native_compressor.flush

          if need_more_destination
            flush_destination_buffer
            next
          end

          read_result

          break
        end

        nil
      end

      def destroy
        raise UsedAfterDestroyError, "compressor used after destroy" if @is_destroyed

        @native_compressor.destroy

        @is_destroyed = true

        nil
      end

      protected def flush_destination_buffer
        result_length = read_result
        raise NotEnoughDestinationError, "not enough destination" if result_length == 0
      end

      protected def read_result
        result = @native_compressor.read_result
        @writer.call result

        result.length
      end
    end
  end
end
