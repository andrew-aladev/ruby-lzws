# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "lzws_ext"

require_relative "abstract"
require_relative "../error"
require_relative "../option"

module LZWS
  module Stream
    class Compressor < Abstract
      def initialize(writer, options = {})
        options       = Option.get_compressor_options options
        native_stream = NativeCompressor.new options

        super writer, native_stream

        @need_to_write_magic_header = !options[:without_magic_header]
      end

      def write(source)
        do_not_use_after_close

        if @need_to_write_magic_header
          write_magic_header
          @need_to_write_magic_header = false
        end

        total_write_length = 0

        loop do
          write_length, need_more_destination = @native_stream.write source

          total_write_length += write_length

          if need_more_destination
            source = source[write_length..-1]
            flush_destination_buffer
            next
          end

          if write_length != source.length
            # Compressor write should eat all provided "source" without remainder.
            raise UnexpectedError, "unexpected error"
          end

          break
        end

        total_write_length
      end

      protected def write_magic_header
        loop do
          need_more_destination = @native_stream.write_magic_header

          if need_more_destination
            flush_destination_buffer
            next
          end

          break
        end

        nil
      end

      def flush
        do_not_use_after_close

        loop do
          need_more_destination = @native_stream.flush

          if need_more_destination
            flush_destination_buffer
            next
          end

          break
        end

        super
      end

      protected def do_not_use_after_close
        raise UsedAfterCloseError, "compressor used after close" if @is_closed
      end
    end
  end
end
