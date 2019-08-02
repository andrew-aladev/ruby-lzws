# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require_relative "abstract"
require_relative "reader_helpers"
require_relative "raw/decompressor"
require_relative "../error"
require_relative "../validation"

module LZWS
  module Stream
    class Reader < Abstract
      include ReaderHelpers

      DEFAULT_IO_PORTION_BYTESIZE = 1 << 12

      def initialize(source_io, options = {}, *args)
        @options = options

        super source_io, *args

        io_portion_bytesize = @options[:io_portion_bytesize]
        @options.delete :io_portion_bytesize

        Validation.validate_positive_integer io_portion_bytesize unless io_portion_bytesize.nil?
        @io_portion_bytesize = io_portion_bytesize || DEFAULT_IO_PORTION_BYTESIZE

        reset_io_remainder
      end

      def create_raw_stream
        Raw::Decompressor.new @options
      end

      protected def reset_io_remainder
        @io_remainder = ::String.new :encoding => ::Encoding::BINARY
      end

      # -- synchronous --

      def read(bytes_to_read = nil, out_buffer = nil)
        Validation.validate_not_negative_integer bytes_to_read unless bytes_to_read.nil?
        Validation.validate_string out_buffer unless out_buffer.nil?

        return ::String.new :encoding => ::Encoding::BINARY if bytes_to_read == 0

        unless bytes_to_read.nil?
          return nil if eof?

          read_more_buffer until @buffer.bytesize >= bytes_to_read || @io.eof?

          bytes_read = [@buffer.bytesize, bytes_to_read].min

          # Result uses buffer binary encoding.
          result   = @buffer.byteslice 0, bytes_read
          @buffer  = @buffer.byteslice bytes_read, @buffer.bytesize - bytes_read
          @pos    += bytes_read

          result = out_buffer.replace result unless out_buffer.nil?

          return result
        end

        read_more_buffer until @io.eof?

        result = @buffer
        reset_buffer
        @pos += result.bytesize

        result = transcode result
        result = out_buffer.replace result unless out_buffer.nil?

        result
      end

      protected def read_more_buffer
        io_portion    = @io_remainder + @io.read(@io_portion_bytesize)
        bytes_read    = raw_wrapper :read, io_portion
        @io_remainder = io_portion.byteslice bytes_read, io_portion.bytesize - bytes_read

        # We should just ignore case when "io.eof?" appears but "io_remainder" is not empty.
        # Ancient compress implementations can write bytes from not initialized buffer parts to output.
        raw_wrapper :flush if @io.eof?
      end

      def rewind
        raw_wrapper :close

        reset_io_remainder

        super
      end

      def close
        raw_wrapper :close

        super
      end

      # -- asynchronous --

      # -- common --

      def eof?
        @io.eof? && @buffer.bytesize == 0
      end

      protected def transcode(result)
        # Transcoding from external to internal encoding.
        result.force_encoding @external_encoding unless @external_encoding.nil?
        result = @buffer.encode @internal_encoding, @transcode_options unless @internal_encoding.nil?
        result
      end

      protected def raw_wrapper(method_name, *args)
        @raw_stream.send(method_name, *args) { |portion| @buffer << portion }
      end
    end
  end
end
