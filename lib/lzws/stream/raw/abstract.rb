# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "lzws_ext"

require_relative "../../error"
require_relative "../../validation"

module LZWS
  module Stream
    module Raw
      class Abstract
        def initialize(native_stream)
          @native_stream = native_stream
          @is_closed     = false
        end

        def close(&writer)
          return nil if @is_closed

          flush(&writer)

          @native_stream.close
          @is_closed = true

          nil
        end

        def closed?
          @is_closed
        end

        protected def flush_destination_buffer(&writer)
          result_bytesize = write_result(&writer)
          raise NotEnoughDestinationError, "not enough destination" if result_bytesize == 0
        end

        protected def write_result(&_writer)
          result = @native_stream.read_result
          yield result

          result.bytesize
        end
      end
    end
  end
end
