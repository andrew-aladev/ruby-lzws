# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require_relative "abstract"
require_relative "reader_helpers"
require_relative "raw/decompressor"
require_relative "../validation"

module LZWS
  module Stream
    class Reader < Abstract
      include ReaderHelpers

      DEFAULT_IO_CHUNK_SIZE = 4096

      def initialize(source_io, options = {}, *args)
        @options = options

        super source_io, *args

        io_chunk_size = @options[:io_chunk_size]
        @options.delete :io_chunk_size

        Validation.validate_positive_integer io_chunk_size unless io_chunk_size.nil?
        @io_chunk_size = io_chunk_size || DEFAULT_IO_CHUNK_SIZE
      end

      def create_raw_stream
        Raw::Decompressor.new @options
      end

      # -- synchronous --

      def read(bytes_to_read = nil, out_buffer = nil)
        Validation.validate_not_negative_integer bytes_to_read unless bytes_to_read.nil?
        Validation.validate_string out_buffer unless out_buffer.nil?

        return "".b if bytes_to_read == 0

        unless bytes_to_read.nil?
          return nil if eof?

          read_more_buffer until @buffer.bytesize >= bytes_to_read || @io.eof?

          bytes_read = Math.min @buffer.bytesize, bytes_to_read

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

        # Transcoding result from external to internal encoding.
        result.force_encoding @external_encoding unless @external_encoding.nil?
        result = @buffer.encode @internal_encoding, @transcode_options unless @internal_encoding.nil?
        result = out_buffer.replace result unless out_buffer.nil?

        result
      end

      protected def read_more_buffer
        chunk = @io.read @io_chunk_size
        raw_wrapper :read, chunk

        raw_wrapper :flush if @io.eof?
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

      protected def raw_wrapper(method_name, *args)
        @raw_stream.send(method_name, *args) { |portion| @buffer << portion }
      end
    end
  end
end
