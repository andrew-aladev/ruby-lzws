# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require_relative "../validation"

module LZWS
  module Stream
    class AbstractIO
      # LZWS native stream is not seekable by design.
      # Related methods like "seek" and "pos=" can't be implemented.

      # Internal encoding for native stream is binary only by design.
      # But it is possible to set external encoding.

      def initialize(io, processor, external_encoding: nil)
        Validation.validate_io io
        @io = io

        @processor = processor

        @buffer = StringIO.new
        @buffer.set_encoding Encoding::BINARY

        @pos = 0
      end

      def set_encoding(external_encoding)
        @external_encoding = external_encoding
      end

      # close
      # closed?
      # flush
      # pos
      # tell
    end
  end
end
