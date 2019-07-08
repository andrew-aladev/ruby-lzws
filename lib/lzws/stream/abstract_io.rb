# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require_relative "../validation"

module LZWS
  module Stream
    class AbstractIO
      # LZWS native stream is not seekable by design.
      # Related methods like "seek" and "pos=" can't be implemented.

      # Internal encoding for native stream is binary only by design.
      # You can set external encoding.

      attr_reader :external_encoding
      attr_reader :pos

      def initialize(processor, io, external_encoding: nil)
        @processor = processor

        Validation.validate_io io
        @io = io

        set_encoding external_encoding

        @buffer = StringIO.new
        @buffer.set_encoding Encoding::BINARY

        @pos = 0
      end

      def set_encoding(*args)
        raise ArgumentError, "wrong number of arguments: Expected 1-3, got #{args.count}" if
          args.count < 1 || args.count > 3

        external_encoding = args.first
        if external_encoding.nil?
          @external_encoding = Encoding.default_external
          return self
        end

        begin
          @external_encoding = Encoding.find external_encoding
        rescue ArgumentError
          raise ValidateError, "invalid external encoding"
        end

        self
      end

      def to_io
        self
      end

      # close
      # closed?
      # flush
      # pos
      # tell
    end
  end
end
