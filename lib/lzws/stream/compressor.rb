# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "lzws_ext"

require_relative "abstract_processor"
require_relative "../error"
require_relative "../option"
require_relative "../validation"

module LZWS
  module Stream
    class Compressor < AbstractProcessor
      def initialize(options = {})
        options       = Option.get_compressor_options options
        native_stream = NativeCompressor.new options

        super native_stream

        @need_to_write_magic_header = !options[:without_magic_header]
      end

      def write(source, &writer)
        do_not_use_after_close

        Validation.validate_string source
        Validation.validate_proc writer

        if @need_to_write_magic_header
          write_magic_header(&writer)
          @need_to_write_magic_header = false
        end

        total_bytes_written = 0

        loop do
          bytes_written, need_more_destination = @native_stream.write source

          total_bytes_written += bytes_written

          if need_more_destination
            source = source.byteslice bytes_written, source.bytesize - bytes_written
            flush_destination_buffer(&writer)
            next
          end

          if bytes_written != source.bytesize
            # Compressor write should eat all provided "source" without remainder.
            raise UnexpectedError, "unexpected error"
          end

          break
        end

        total_bytes_written
      end

      protected def write_magic_header(&writer)
        loop do
          need_more_destination = @native_stream.write_magic_header

          if need_more_destination
            flush_destination_buffer(&writer)
            next
          end

          break
        end

        nil
      end

      def flush(&writer)
        do_not_use_after_close

        Validation.validate_proc writer

        loop do
          need_more_destination = @native_stream.flush

          if need_more_destination
            flush_destination_buffer(&writer)
            next
          end

          break
        end

        write_result(&writer)

        nil
      end

      protected def do_not_use_after_close
        raise UsedAfterCloseError, "compressor used after close" if @is_closed
      end
    end
  end
end
