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

          out_buffer = ::String.new if out_buffer.nil?
          out_buffer.force_encoding Encoding::BINARY unless out_buffer.encoding == Encoding::BINARY

          while @buffer.bytesize < bytes_to_read
            read_more_buffer
            break if @io.eof?
          end

          # TODO
        end

        # TODO
        "".b
      end

      protected def read_more_buffer
        chunk = @io.read @io_chunk_size

        raw_proxy :read, chunk
        raw_proxy :close if @io.eof?
      end

      # -- common --

      def eof?
        @io.eof? && @buffer.bytesize == 0
      end

      protected def prepare_destination_for_read(source)
        if @internal_encoding.nil?
          source
        else
          source.encode @internal_encoding, @transcode_options
        end
      end

      protected def raw_proxy(method_name, *args)
        @raw_stream.send(method_name, *args) { |portion| @buffer << portion }
      end
    end
  end
end
