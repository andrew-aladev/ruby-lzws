# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "lzws_ext"

require_relative "../validation"

module LZWS
  module Stream
    class Abstract
      def initialize(writer, native_stream)
        Validation.validate_proc writer
        @writer = writer

        @native_stream = native_stream
        @is_closed     = false
      end

      def close
        return nil if @is_closed

        flush

        @native_stream.close
        @is_closed = true

        nil
      end

      def flush
        write_result

        nil
      end

      def closed?
        @is_closed
      end

      protected def flush_destination_buffer
        result_length = write_result
        raise NotEnoughDestinationError, "not enough destination" if result_length == 0
      end

      protected def write_result
        result = @native_stream.read_result
        @writer.call result

        result.length
      end
    end
  end
end
