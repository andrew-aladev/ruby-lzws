# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require_relative "../error"
require_relative "../validation"

module LZWS
  module Stream
    class Abstract
      # LZWS native stream is not seekable by design.
      # Related methods like "seek" and "pos=" can't be implemented.

      attr_reader :external_encoding
      attr_reader :internal_encoding
      attr_reader :pos

      def initialize(raw_stream, io, external_encoding: nil, internal_encoding: nil, transcode_options: {})
        @raw_stream = raw_stream

        Validation.validate_io io
        @io = io

        set_encoding external_encoding, internal_encoding, transcode_options
        reset_buffer

        @pos = 0
      end

      protected def reset_buffer
        @buffer = self.class.new_buffer
      end

      def self.new_buffer
        ::String.new :encoding => Encoding::BINARY
      end

      def set_encoding(*args)
        external_encoding, internal_encoding, transcode_options = process_set_encoding_arguments(*args)

        set_target_encoding :@external_encoding, external_encoding
        set_target_encoding :@internal_encoding, internal_encoding
        @transcode_options = transcode_options

        self
      end

      protected def process_set_encoding_arguments(*args)
        external_encoding = args[0]

        unless external_encoding.nil?
          Validation.validate_string external_encoding

          # First argument can be "external_encoding:internal_encoding".
          match = %r{(.+?):(.+)}.match external_encoding

          unless match.nil?
            external_encoding = match[0]
            internal_encoding = match[1]

            transcode_options = args[1]
            Validation.validate_hash transcode_options unless transcode_options.nil?

            return [external_encoding, internal_encoding, transcode_options]
          end
        end

        internal_encoding = args[1]
        Validation.validate_string internal_encoding unless internal_encoding.nil?

        transcode_options = args[2]
        Validation.validate_hash transcode_options unless transcode_options.nil?

        [external_encoding, internal_encoding, transcode_options]
      end

      protected def set_target_encoding(name, value)
        unless value.nil?
          begin
            value = Encoding.find value
          rescue ArgumentError
            raise ValidateError, "invalid #{name} encoding"
          end
        end

        instance_variable_set name, value
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
