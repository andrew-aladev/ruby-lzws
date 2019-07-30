# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require_relative "abstract"
require_relative "writer_helpers"
require_relative "raw/compressor"

module LZWS
  module Stream
    class Writer < Abstract
      include WriterHelpers

      def initialize(destination_io, options = {}, *args)
        @options = options

        super destination_io, *args
      end

      def create_raw_stream
        Raw::Compressor.new @options
      end

      # -- synchronous --

      def write(*objects)
        write_remaining_buffer

        source_bytes_written = 0

        objects.each do |object|
          source                = prepare_source_for_write object.to_s
          source_bytes_written += raw_proxy :write, source
        end

        @pos += source_bytes_written

        source_bytes_written
      end

      def flush
        finish :flush

        @io.flush

        self
      end

      def close
        finish :close

        super
      end

      protected def finish(method_name)
        write_remaining_buffer

        raw_proxy method_name
      end

      protected def write_remaining_buffer
        return nil if @buffer.bytesize == 0

        @io.write @buffer

        reset_buffer
      end

      protected def raw_proxy(method_name, *args)
        @raw_stream.send(method_name, *args) { |portion| @io.write portion }
      end

      # -- asynchronous --

      def write_nonblock(object, *options)
        return 0 unless write_remaining_buffer_nonblock(*options)

        source                = prepare_source_for_write object.to_s
        source_bytes_written  = raw_nonblock_proxy :write, source
        @pos                 += source_bytes_written

        source_bytes_written
      end

      def flush_nonblock(*options)
        return false unless finish_nonblock :flush, *options

        @io.flush

        true
      end

      def close_nonblock(*options)
        return false unless finish_nonblock :close, *options

        method(:close).super_method.call

        true
      end

      protected def finish_nonblock(method_name, *options)
        return false unless write_remaining_buffer_nonblock(*options)

        raw_nonblock_proxy method_name

        write_remaining_buffer_nonblock(*options)
      end

      protected def write_remaining_buffer_nonblock(*options)
        return true if @buffer.bytesize == 0

        destination_bytes_written = @io.write_nonblock @buffer, *options
        return false if destination_bytes_written == 0

        @buffer = @buffer.byteslice destination_bytes_written, @buffer.bytesize - destination_bytes_written

        @buffer.bytesize == 0
      end

      protected def raw_nonblock_proxy(method_name, *args)
        @raw_stream.send(method_name, *args) { |portion| @buffer << portion }
      end

      # -- common --

      protected def prepare_source_for_write(source)
        if @external_encoding.nil?
          source
        else
          source.encode @external_encoding, @transcode_options
        end
      end
    end
  end
end
