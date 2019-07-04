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

        @source       = nil
        @is_destroyed = false
      end

      def read_magic_header
        raise UsedAfterDestroyError, "decompressor used after destroy" if @is_destroyed

        @source = @reader.call
        raise NotEnoughSourceError, "not enough source" if @source.nil?

        loop do
          read_length = @native_decompressor.read_magic_header @source

          if read_length == 0
            # Decompressor is not able to read full magic header.

            next_source = @reader.call
            raise NotEnoughSourceError, "not enough source" if next_source.nil?

            @source << next_source

            next
          end

          @source = @source[read_length..-1]

          break
        end

        nil
      end

      def read
        raise UsedAfterDestroyError, "decompressor used after destroy" if @is_destroyed

        if @source.nil?
          @source = @reader.call
          raise NotEnoughSourceError, "not enough source" if @source.nil?
        end

        loop do
          read_length, need_more_destination = @native_decompressor.read @source

          @source = @source[read_length..-1]

          if need_more_destination
            flush_destination_buffer
            next
          end

          next_source = @reader.call
          break if next_source.nil?

          @source << next_source
        end

        read_result

        nil
      end

      def destroy
        raise UsedAfterDestroyError, "decompressor used after destroy" if @is_destroyed

        @native_decompressor.destroy

        @is_destroyed = true

        nil
      end

      protected def flush_destination_buffer
        result_length = read_result
        raise NotEnoughDestinationError, "not enough destination" if result_length == 0
      end

      protected def read_result
        result = @native_decompressor.read_result
        @writer.call result

        result.length
      end
    end
  end
end
