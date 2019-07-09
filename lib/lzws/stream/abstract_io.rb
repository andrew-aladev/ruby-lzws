# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require_relative "../validation"

module LZWS
  module Stream
    class AbstractIO
      # LZWS native stream is not seekable by design.
      # Related methods like "seek" and "pos=" can't be implemented.

      attr_reader :external_encoding
      attr_reader :internal_encoding
      attr_reader :pos

      def initialize(processor, io, external_encoding: nil, internal_encoding: nil, transcode_options: {})
        @processor = processor

        Validation.validate_io io
        @io = io

        set_encoding external_encoding, internal_encoding, transcode_options

        @buffer = StringIO.new
        @buffer.set_encoding Encoding::BINARY

        @pos = 0
      end

      def set_encoding(*args)
        first_arg = args[0]

        if first_arg.nil?
          external_encoding = nil
          internal_encoding = args[1]
          transcode_options = args[2]
        else
          Validation.validate_string first_arg

          # First argument can be "external_encoding:internal_encoding".
          match = %r{(.+?):(.+)}.match first_arg

          if match.nil?
            external_encoding = first_arg
            internal_encoding = args[1]
            transcode_options = args[2]
          else
            external_encoding = match[0]
            internal_encoding = match[1]
            transcode_options = args[1]
          end
        end

        Validation.validate_string internal_encoding unless internal_encoding.nil?
        Validation.validate_hash transcode_options unless transcode_options.nil?

        set_target_encoding :@external_encoding, external_encoding
        set_target_encoding :@internal_encoding, internal_encoding
        @transcode_options = transcode_options

        self
      end

      protected def set_target_encoding(name, value)
        if value.nil?
          instance_variable_set name, nil
          return nil
        end

        begin
          encoding = Encoding.find value
        rescue ArgumentError
          raise ValidateError, "invalid #{name} encoding"
        end

        instance_variable_set name, encoding
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
