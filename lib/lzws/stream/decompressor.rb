# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "lzws_ext"

require_relative "abstract_processor"
require_relative "../error"
require_relative "../option"
require_relative "../validation"

module LZWS
  module Stream
    class Decompressor < AbstractProcessor
      def initialize(options = {})
        options       = Option.get_decompressor_options options
        native_stream = NativeDecompressor.new options

        super native_stream

        @need_to_read_magic_header = !options[:without_magic_header]
      end

      def read(source, &writer)
        do_not_use_after_close

        Validation.validate_string source
        Validation.validate_proc writer

        total_read_length = 0

        if @need_to_read_magic_header
          read_length = @native_stream.read_magic_header source
          if read_length == 0
            # Decompressor is not able to read full magic header.
            return 0
          end

          total_read_length += read_length
          source             = source[read_length..-1]

          @need_to_read_magic_header = false
        end

        loop do
          read_length, need_more_destination = @native_stream.read source

          total_read_length += read_length

          if need_more_destination
            source = source[read_length..-1]
            flush_destination_buffer(&writer)
            next
          end

          break
        end

        total_read_length
      end

      def flush(&writer)
        do_not_use_after_close

        Validation.validate_proc writer

        write_result(&writer)

        nil
      end

      protected def do_not_use_after_close
        raise UsedAfterCloseError, "decompressor used after close" if @is_closed
      end
    end
  end
end
