# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "lzws_ext"

require_relative "../validation"

module LZWS
  module Stream
    class Abstract
      attr_reader :pos

      def initialize(writer, native_stream)
        Validation.validate_proc writer
        @writer = writer

        @native_stream = native_stream
        @pos           = 0
        @is_closed     = false
      end

      # read/write
      # eof?
      # getc
      # rewind
      # flush

      def close
        return nil if @is_closed

        @native_stream.destroy

        @is_closed = true

        nil
      end

      def closed?
        @is_closed
      end
    end
  end
end
